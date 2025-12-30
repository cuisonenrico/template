import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final _connectivityController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get onStatusChange =>
      _connectivityController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether the device is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Whether the device is currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Initialize the connectivity service
  Future<void> init() async {
    // Get initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = _parseResults(results);
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _connectivityController.add(newStatus);
    }
  }

  ConnectivityStatus _parseResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  /// Check current connectivity (one-time check)
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _parseResults(results);
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Connectivity status enum
enum ConnectivityStatus { online, offline, unknown }

/// A widget that shows a connectivity banner when offline
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final Widget? offlineBanner;
  final Duration animationDuration;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.offlineBanner,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late StreamSubscription<ConnectivityStatus> _subscription;
  bool _isOffline = false;
  bool _showingReconnected = false;

  @override
  void initState() {
    super.initState();
    _isOffline = ConnectivityService().isOffline;
    _subscription = ConnectivityService().onStatusChange.listen(
      _onStatusChange,
    );
  }

  void _onStatusChange(ConnectivityStatus status) {
    final wasOffline = _isOffline;
    setState(() {
      _isOffline = status == ConnectivityStatus.offline;
    });

    // Show "reconnected" message briefly when coming back online
    if (wasOffline && !_isOffline) {
      setState(() => _showingReconnected = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showingReconnected = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: widget.animationDuration,
          height: _isOffline || _showingReconnected ? null : 0,
          child: AnimatedSwitcher(
            duration: widget.animationDuration,
            child: _isOffline
                ? widget.offlineBanner ?? _defaultOfflineBanner(context)
                : _showingReconnected
                ? _reconnectedBanner(context)
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _defaultOfflineBanner(BuildContext context) {
    return Container(
      key: const ValueKey('offline'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'No internet connection',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reconnectedBanner(BuildContext context) {
    return Container(
      key: const ValueKey('reconnected'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.green.shade700,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Back online',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mixin for widgets that need to react to connectivity changes
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  late StreamSubscription<ConnectivityStatus> _connectivitySubscription;

  bool get isOnline => ConnectivityService().isOnline;
  bool get isOffline => ConnectivityService().isOffline;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = ConnectivityService().onStatusChange.listen(
      onConnectivityChanged,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Override this to handle connectivity changes
  void onConnectivityChanged(ConnectivityStatus status) {}
}

/// Extension for easy connectivity checks
extension ConnectivityContext on BuildContext {
  bool get isOnline => ConnectivityService().isOnline;
  bool get isOffline => ConnectivityService().isOffline;
  Stream<ConnectivityStatus> get connectivityStream =>
      ConnectivityService().onStatusChange;
}
