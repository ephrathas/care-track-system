class ChildModel {
  final String id;
  final String name;
  final int age;
  final String parentId;
  final String imageUrl;
  final List<String> vaccinations;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.parentId,
    required this.imageUrl,
    this.vaccinations = const [],
  });

  // Convert Firebase Document to Flutter Object
  factory ChildModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChildModel(
      id: documentId,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      parentId: map['parentId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      vaccinations: List<String>.from(map['vaccinations'] ?? []),
    );
  }

  // Convert Flutter Object to Map to save to Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'parentId': parentId,
      'imageUrl': imageUrl,
      'vaccinations': vaccinations,
    };
  }
}
