import 'package:barakah/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.fromResponse', () {
    test('galat dari fungsi kita memakai pesannya', () {
      final e = ApiException.fromResponse(409, {
        'error': {'code': 'prev_hash_mismatch', 'message': 'Rantai berbeda.'},
      });
      expect(e.kind, ApiErrorKind.conflict);
      expect(e.code, 'prev_hash_mismatch');
      expect(e.message, 'Rantai berbeda.');
    });

    test('function belum di-deploy dikenali dari gateway Supabase', () {
      final e = ApiException.fromResponse(404, {
        'code': 'NOT_FOUND',
        'message': 'Requested function was not found',
      });
      expect(e.kind, ApiErrorKind.notFound);
      expect(e.code, 'NOT_FOUND');
      expect(e.message, contains('belum di-deploy'));
    });

    test('function gagal start dikenali', () {
      final e = ApiException.fromResponse(503, {
        'code': 'BOOT_ERROR',
        'message': 'Function failed to start (please check logs)',
      });
      expect(e.kind, ApiErrorKind.server);
      expect(e.message, contains('log Edge Function'));
    });

    test('badan tak dikenal memakai pesan bawaan status', () {
      final e = ApiException.fromResponse(404, 'bukan json');
      expect(e.message, 'Data tidak ditemukan.');
      final f = ApiException.fromResponse(500, {'message': 'apa saja'});
      expect(f.message, ApiException.defaultMessage(ApiErrorKind.server));
    });
  });
}
