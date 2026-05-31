import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../models/message_thread_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class MessagingProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<MessageThread> _threads = [];
  List<ChatMessage> _activeMessages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _activeThreadId;
  StreamSubscription<List<MessageThread>>? _threadsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  List<MessageThread> get threads => List.unmodifiable(_threads);
  List<ChatMessage> get activeMessages => List.unmodifiable(_activeMessages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  int unreadCountFor(String userId) =>
      _threads.where((thread) => thread.isUnreadFor(userId)).length;

  void startListeningForParent(String parentId) {
    _listen(_db.getMessageThreadsForParent(parentId));
  }

  void startListeningForTeacher(String teacherId) {
    _listen(_db.getMessageThreadsForTeacher(teacherId));
  }

  void _listen(Stream<List<MessageThread>> stream) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _threadsSubscription?.cancel();
    _threadsSubscription = stream.listen(
      (data) {
        _threads = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void watchThreadMessages(String threadId) {
    if (_activeThreadId == threadId) return;
    _activeThreadId = threadId;
    _activeMessages = [];

    _messagesSubscription?.cancel();
    _messagesSubscription = _db.getChatMessages(threadId).listen(
      (messages) {
        _activeMessages = messages;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  void stopWatchingMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _activeThreadId = null;
    _activeMessages = [];
  }

  Future<MessageThread?> ensureParentTeacherThread({
    required String parentId,
    required String parentName,
  }) async {
    final existing = await _db.findThreadForParent(parentId);
    if (existing != null) return existing;

    final teacher = await _db.getFirstUserByRole('Teacher');
    if (teacher == null) {
      _errorMessage = 'No teacher account found yet. Ask your school to register a teacher.';
      notifyListeners();
      return null;
    }

    final thread = MessageThread(
      id: '',
      parentId: parentId,
      teacherId: teacher.uid,
      parentName: parentName,
      teacherName: teacher.fullName,
      lastMessage: 'Conversation started',
      lastMessageAt: DateTime.now(),
    );

    final id = await _db.createMessageThread(thread);
    return MessageThread(
      id: id,
      parentId: thread.parentId,
      teacherId: thread.teacherId,
      parentName: thread.parentName,
      teacherName: thread.teacherName,
      lastMessage: thread.lastMessage,
      lastMessageAt: thread.lastMessageAt,
    );
  }

  Future<void> sendMessage({
    required MessageThread thread,
    required UserModel sender,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      final message = ChatMessage(
        id: '',
        threadId: thread.id,
        senderId: sender.uid,
        senderRole: sender.role,
        senderName: sender.fullName,
        text: trimmed,
        createdAt: DateTime.now(),
      );

      await _db.sendChatMessage(
        threadId: thread.id,
        message: message,
        senderIsParent: sender.role == 'Parent',
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markThreadRead({
    required MessageThread thread,
    required String userId,
  }) async {
    if (!thread.isUnreadFor(userId)) return;
    try {
      await _db.markThreadRead(
        threadId: thread.id,
        forParent: userId == thread.parentId,
      );
    } catch (e) {
      debugPrint('markThreadRead error: $e');
    }
  }

  void stopListening() {
    _threadsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _threadsSubscription = null;
    _messagesSubscription = null;
    _threads = [];
    _activeMessages = [];
    _activeThreadId = null;
    _isLoading = false;
    _isSending = false;
    _errorMessage = null;
    notifyListeners();
  }
}
