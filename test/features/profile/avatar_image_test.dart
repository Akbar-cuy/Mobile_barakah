import 'dart:typed_data';

import 'package:barakah/features/profile/services/avatar_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 1]);
  final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0]);
  final webp = Uint8List.fromList(
      [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50, 1]);

  test('jenis gambar dikenali dari byte, bukan nama berkas', () {
    expect(AvatarImage.detectContentType(jpeg), 'image/jpeg');
    expect(AvatarImage.detectContentType(png), 'image/png');
    expect(AvatarImage.detectContentType(webp), 'image/webp');
    expect(AvatarImage.detectContentType(Uint8List.fromList([0x47, 0x49, 0x46])), isNull);
    expect(AvatarImage.detectContentType(Uint8List(0)), isNull);
  });

  test('validate menolak bukan gambar dan yang lebih dari 1 MB', () {
    expect(AvatarImage.validate(png).contentType, 'image/png');
    expect(() => AvatarImage.validate(Uint8List.fromList([1, 2, 3, 4])),
        throwsA(isA<AvatarFormatException>()));
    final big = Uint8List(AvatarImage.maxBytes + 1)..setRange(0, 3, jpeg);
    expect(() => AvatarImage.validate(big), throwsA(isA<AvatarTooLargeException>()));
    final edge = Uint8List(AvatarImage.maxBytes)..setRange(0, 3, jpeg);
    expect(AvatarImage.validate(edge).bytes.length, AvatarImage.maxBytes);
  });
}
