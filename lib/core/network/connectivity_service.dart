// Fondasi lintas fitur. Deteksi online dan offline (offline first, M20).
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  // connectivity_plus 5 mengembalikan satu nilai, versi 6 mengembalikan daftar.
  static bool _isOnline(Object result) {
    if (result is List) {
      return result.any((e) => e != ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }

  Future<bool> isOnline() async => _isOnline(await _connectivity.checkConnectivity());

  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();
}
