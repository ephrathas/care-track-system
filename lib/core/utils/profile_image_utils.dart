import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Resize/compress profile photos before Firebase upload (faster on slow networks).
Future<Uint8List> compressProfilePhotoBytes(Uint8List raw) async {
  try {
    final decoded = img.decodeImage(raw);
    if (decoded == null) return raw;

    final resized = img.copyResize(
      decoded,
      width: 320,
      height: 320,
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: 72));
  } catch (_) {
    return raw;
  }
}
