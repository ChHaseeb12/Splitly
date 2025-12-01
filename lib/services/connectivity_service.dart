import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(result);

      // Only emit if status changed
      if (wasOnline != _isOnline) {
        _connectivityController?.add(_isOnline);
        print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      }
    });
  }

  /// Check if connected based on connectivity result
  bool _isConnected(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
  }
}
