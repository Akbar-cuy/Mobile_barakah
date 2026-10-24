// M17 Profil (FR-PRO-03). Foto profil dari galeri atau kamera.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum AvatarSource { gallery, camera }

class PickedAvatar {
  const PickedAvatar({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

class AvatarTooLargeException implements Exception {
  const AvatarTooLargeException();
}

class AvatarFormatException implements Exception {
  const AvatarFormatException();
}

abstract final class AvatarImage {
  /// Batas yang sama dengan server.
  static const int maxBytes = 1024 * 1024;

  /// Jenis gambar dari byte pertamanya, atau null bila bukan JPEG, PNG, atau
  /// WebP. Nama berkas tidak dipercaya.
  static String? detectContentType(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47 &&
        b[4] == 0x0D &&
        b[5] == 0x0A &&
        b[6] == 0x1A &&
        b[7] == 0x0A) {
      return 'image/png';
    }
    if (b.length >= 12 &&
        b[0] == 0x52 && // R
        b[1] == 0x49 && // I
        b[2] == 0x46 && // F
        b[3] == 0x46 && // F
        b[8] == 0x57 && // W
        b[9] == 0x45 && // E
        b[10] == 0x42 && // B
        b[11] == 0x50) {
      // P
      return 'image/webp';
    }
    return null;
  }

  /// Memeriksa byte hasil pilihan. Melempar [AvatarFormatException] atau
  /// [AvatarTooLargeException].
  static PickedAvatar validate(Uint8List bytes) {
    final type = detectContentType(bytes);
    if (type == null) throw const AvatarFormatException();
    if (bytes.length > maxBytes) throw const AvatarTooLargeException();
    return PickedAvatar(bytes: bytes, contentType: type);
  }
}

/// Membungkus image_picker agar layar dapat diuji dengan pengganti.
class AvatarPickerService {
  const AvatarPickerService();

  /// Null bila pengguna membatalkan.
  Future<PickedAvatar?> pick(AvatarSource source) async {
    final file = await ImagePicker().pickImage(
      source: source == AvatarSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    return AvatarImage.validate(await file.readAsBytes());
  }
}

final avatarPickerServiceProvider =
    Provider<AvatarPickerService>((ref) => const AvatarPickerService());
