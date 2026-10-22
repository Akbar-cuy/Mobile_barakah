// M21 IoT Opsional (FR-IOT)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../models/iot_device.dart';
import '../repository/iot_repository.dart';

final iotRepositoryProvider = Provider<IotRepository>((ref) {
  return ApiIotRepository(
    api: ref.watch(apiGatewayProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});

final iotDevicesProvider = FutureProvider.autoDispose<List<IotDevice>>(
  (ref) => ref.watch(iotRepositoryProvider).devices(),
);

/// Galat yang pesannya siap ditampilkan ke pengguna.
class IotException implements Exception {
  const IotException(this.message);
  final String message;
}

class IotActions {
  IotActions(this._ref);

  final Ref _ref;

  /// Mengembalikan perangkat (dengan token) atau melempar [IotException].
  Future<IotDevice> register(String name) async {
    try {
      final d = await _ref.read(iotRepositoryProvider).register(name.trim());
      _ref.invalidate(iotDevicesProvider);
      return d;
    } on ApiException catch (e) {
      throw IotException(e.isConnectivity ? 'Tidak ada koneksi. Coba lagi saat online.' : e.message);
    } catch (_) {
      throw const IotException('Perangkat gagal didaftarkan.');
    }
  }

  Future<void> forget(String id) async {
    await _ref.read(iotRepositoryProvider).forget(id);
    _ref.invalidate(iotDevicesProvider);
  }
}

final iotActionsProvider = Provider<IotActions>((ref) => IotActions(ref));
