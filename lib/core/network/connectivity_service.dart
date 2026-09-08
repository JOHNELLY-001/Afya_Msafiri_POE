import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(
          (results) => !results.contains(ConnectivityResult.none),
    );
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}