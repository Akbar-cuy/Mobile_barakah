// M21 IoT Opsional (FR-IOT)
class IotDevice {
  const IotDevice({
    required this.id,
    required this.name,
    required this.registeredAt,
    this.token,
  });

  /// Respons POST /iot/devices. Kunci dibaca longgar (id/device_id,
  /// token/device_token).
  factory IotDevice.fromResponse(Map<String, dynamic> res, {required String name, DateTime? now}) {
    final raw = (res['device'] ?? res['data'] ?? res) as Map;
    final j = raw.cast<String, dynamic>();
    final id = (j['id'] ?? j['device_id'])?.toString();
    if (id == null) throw const FormatException('id perangkat tidak ada');
    return IotDevice(
      id: id,
      name: (j['name'] ?? name).toString(),
      token: (j['token'] ?? j['device_token'] ?? res['token'] ?? res['device_token'])?.toString(),
      registeredAt: now ?? DateTime.now(),
    );
  }

  factory IotDevice.fromJson(Map<String, dynamic> j) => IotDevice(
        id: j['id'].toString(),
        name: j['name'].toString(),
        registeredAt: DateTime.tryParse('${j['registered_at']}') ?? DateTime.now(),
      );

  final String id;
  final String name;
  final DateTime registeredAt;

  /// Hanya ada tepat setelah pendaftaran. Tidak disimpan di perangkat ini.
  final String? token;

  /// Token sengaja tidak ikut tersimpan.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'registered_at': registeredAt.toUtc().toIso8601String(),
      };
}
