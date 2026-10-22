// M17 Profil
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../repository/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    api: ref.watch(apiGatewayProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});

/// Status sinkronisasi sebagai stream untuk antarmuka (FR-SYNC-04).
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  yield service.status;
  yield* service.statusStream;
});

class BiometricStatus {
  const BiometricStatus({required this.enabled, required this.availability});

  final bool enabled;
  final BiometricAvailability availability;
}

final biometricStatusProvider = FutureProvider<BiometricStatus>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return BiometricStatus(
    enabled: await service.isEnabled(),
    availability: await service.availability(),
  );
});
