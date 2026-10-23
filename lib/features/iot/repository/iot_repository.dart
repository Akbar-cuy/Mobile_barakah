// M21 IoT Opsional (FR-IOT-01, FR-IOT-02)
import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../models/iot_device.dart';

abstract interface class IotRepository {
  Future<List<IotDevice>> devices();

  /// Mendaftarkan perangkat. Token pada hasilnya hanya ditampilkan sekali.
  Future<IotDevice> register(String name);

  /// Menghapus dari daftar di perangkat ini.
  Future<void> forget(String id);
}

class ApiIotRepository implements IotRepository {
  ApiIotRepository({required this.api, required this.settings});

  final ApiGateway api;
  final SettingsDao settings;

  static const _key = 'iot_devices';

  @override
  Future<List<IotDevice>> devices() async {
    final raw = await settings.get(_key);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          IotDevice.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<IotDevice> register(String name) async {
    final res = await api
        .request('POST', ApiEndpoints.iotDevices, body: {'name': name});
    final device = IotDevice.fromResponse(res, name: name);
    final all = [...await devices(), device];
    await settings.set(_key, jsonEncode([for (final d in all) d.toJson()]));
    return device;
  }

  @override
  Future<void> forget(String id) async {
    await api.request('DELETE', ApiEndpoints.iotDevice(id));
    final all = [
      for (final d in await devices())
        if (d.id != id) d
    ];
    await settings.set(_key, jsonEncode([for (final d in all) d.toJson()]));
  }
}
