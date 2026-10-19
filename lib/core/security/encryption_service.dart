// Keamanan: FR-AUTH-07 (kunci enkripsi basis data lokal)
import '../constants/app_constants.dart';
import 'hash_utils.dart';
import 'secure_storage_service.dart';

class EncryptionService {
  EncryptionService(this._storage);

  final SecureStorageService _storage;

  Future<String> getOrCreateDatabaseKey() =>
      _getOrCreate(SecureKeys.dbEncryptionKey, 32);

  Future<String> getOrCreateDeviceId() => _getOrCreate(SecureKeys.deviceId, 16);

  Future<String> _getOrCreate(String key, int bytes) async {
    final existing = await _storage.read(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = HashUtils.randomHex(bytes);
    await _storage.write(key, created);
    return created;
  }
}
