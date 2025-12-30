import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Abstract analytics provider interface
/// Implement this for different analytics services (Firebase, Mixpanel, Amplitude, etc.)
abstract class AnalyticsProvider {
  /// Initialize the analytics provider
  Future<void> init();

  /// Set user ID for analytics
  Future<void> setUserId(String? userId);

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Log a custom event
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);

  /// Log a screen view
  Future<void> logScreenView(String screenName, [String? screenClass]);

  /// Log a purchase event
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    List<AnalyticsItem>? items,
  });

  /// Log login event
  Future<void> logLogin(String method);

  /// Log sign up event
  Future<void> logSignUp(String method);

  /// Log share event
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  });

  /// Reset analytics (on logout)
  Future<void> reset();

  /// Enable or disable analytics collection
  Future<void> setEnabled(bool enabled);
}

/// Analytics item for purchase events
class AnalyticsItem {
  final String itemId;
  final String? itemName;
  final String? itemCategory;
  final double? price;
  final int quantity;

  const AnalyticsItem({
    required this.itemId,
    this.itemName,
    this.itemCategory,
    this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'item_id': itemId,
    if (itemName != null) 'item_name': itemName,
    if (itemCategory != null) 'item_category': itemCategory,
    if (price != null) 'price': price,
    'quantity': quantity,
  };
}

/// Debug analytics provider that logs to console
class DebugAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> init() async {
    AppLogger().debug('[Analytics] Initialized (Debug Mode)');
  }

  @override
  Future<void> setUserId(String? userId) async {
    AppLogger().debug('[Analytics] Set User ID: $userId');
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    AppLogger().debug('[Analytics] Set User Properties: $properties');
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    AppLogger().debug('[Analytics] Event: $name, Params: $parameters');
  }

  @override
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    AppLogger().debug(
      '[Analytics] Screen View: $screenName, Class: $screenClass',
    );
  }

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    List<AnalyticsItem>? items,
  }) async {
    AppLogger().debug(
      '[Analytics] Purchase: $currency $value, Transaction: $transactionId',
    );
  }

  @override
  Future<void> logLogin(String method) async {
    AppLogger().debug('[Analytics] Login: $method');
  }

  @override
  Future<void> logSignUp(String method) async {
    AppLogger().debug('[Analytics] Sign Up: $method');
  }

  @override
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    AppLogger().debug(
      '[Analytics] Share: $contentType, $itemId, Method: $method',
    );
  }

  @override
  Future<void> reset() async {
    AppLogger().debug('[Analytics] Reset');
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    AppLogger().debug('[Analytics] Enabled: $enabled');
  }
}

/// No-op analytics provider (for when analytics is disabled)
class NoOpAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> init() async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}
  @override
  Future<void> logEvent(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {}
  @override
  Future<void> logScreenView(String screenName, [String? screenClass]) async {}
  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    List<AnalyticsItem>? items,
  }) async {}
  @override
  Future<void> logLogin(String method) async {}
  @override
  Future<void> logSignUp(String method) async {}
  @override
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {}
  @override
  Future<void> reset() async {}
  @override
  Future<void> setEnabled(bool enabled) async {}
}

/// Multi-provider analytics that sends to multiple providers
class MultiAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsProvider> providers;

  MultiAnalyticsProvider(this.providers);

  @override
  Future<void> init() async {
    await Future.wait(providers.map((p) => p.init()));
  }

  @override
  Future<void> setUserId(String? userId) async {
    await Future.wait(providers.map((p) => p.setUserId(userId)));
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    await Future.wait(providers.map((p) => p.setUserProperties(properties)));
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    await Future.wait(providers.map((p) => p.logEvent(name, parameters)));
  }

  @override
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    await Future.wait(
      providers.map((p) => p.logScreenView(screenName, screenClass)),
    );
  }

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    List<AnalyticsItem>? items,
  }) async {
    await Future.wait(
      providers.map(
        (p) => p.logPurchase(
          currency: currency,
          value: value,
          transactionId: transactionId,
          items: items,
        ),
      ),
    );
  }

  @override
  Future<void> logLogin(String method) async {
    await Future.wait(providers.map((p) => p.logLogin(method)));
  }

  @override
  Future<void> logSignUp(String method) async {
    await Future.wait(providers.map((p) => p.logSignUp(method)));
  }

  @override
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await Future.wait(
      providers.map(
        (p) => p.logShare(
          contentType: contentType,
          itemId: itemId,
          method: method,
        ),
      ),
    );
  }

  @override
  Future<void> reset() async {
    await Future.wait(providers.map((p) => p.reset()));
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    await Future.wait(providers.map((p) => p.setEnabled(enabled)));
  }
}

/// Central analytics service
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late AnalyticsProvider _provider;
  bool _initialized = false;

  /// Initialize analytics with a provider
  ///
  /// Usage:
  /// ```dart
  /// await AnalyticsService().init(
  ///   kDebugMode ? DebugAnalyticsProvider() : FirebaseAnalyticsProvider(),
  /// );
  /// ```
  Future<void> init(AnalyticsProvider provider) async {
    _provider = provider;
    await _provider.init();
    _initialized = true;
  }

  /// Get the provider (for direct access if needed)
  AnalyticsProvider get provider {
    _checkInitialized();
    return _provider;
  }

  void _checkInitialized() {
    if (!_initialized) {
      if (kDebugMode) {
        AppLogger().warning('Analytics not initialized, using NoOp provider');
      }
      _provider = NoOpAnalyticsProvider();
      _initialized = true;
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    _checkInitialized();
    await _provider.setUserId(userId);
  }

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    _checkInitialized();
    await _provider.setUserProperties(properties);
  }

  /// Log custom event
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    _checkInitialized();
    await _provider.logEvent(name, parameters);
  }

  /// Log screen view
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    _checkInitialized();
    await _provider.logScreenView(screenName, screenClass);
  }

  /// Log purchase
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    List<AnalyticsItem>? items,
  }) async {
    _checkInitialized();
    await _provider.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
      items: items,
    );
  }

  /// Log login
  Future<void> logLogin(String method) async {
    _checkInitialized();
    await _provider.logLogin(method);
  }

  /// Log sign up
  Future<void> logSignUp(String method) async {
    _checkInitialized();
    await _provider.logSignUp(method);
  }

  /// Log share
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    _checkInitialized();
    await _provider.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  /// Reset analytics
  Future<void> reset() async {
    _checkInitialized();
    await _provider.reset();
  }

  /// Enable or disable analytics
  Future<void> setEnabled(bool enabled) async {
    _checkInitialized();
    await _provider.setEnabled(enabled);
  }
}

/// Common analytics events
class AnalyticsEvents {
  AnalyticsEvents._();

  // Button taps
  static Future<void> buttonTap(String buttonName) =>
      AnalyticsService().logEvent('button_tap', {'button_name': buttonName});

  // Feature usage
  static Future<void> featureUsed(String featureName) => AnalyticsService()
      .logEvent('feature_used', {'feature_name': featureName});

  // Search
  static Future<void> search(String query) =>
      AnalyticsService().logEvent('search', {'search_term': query});

  // Item view
  static Future<void> viewItem(String itemId, String itemType) =>
      AnalyticsService().logEvent('view_item', {
        'item_id': itemId,
        'item_type': itemType,
      });

  // Error occurred
  static Future<void> error(String errorType, String message) =>
      AnalyticsService().logEvent('error', {
        'error_type': errorType,
        'error_message': message,
      });

  // Tutorial progress
  static Future<void> tutorialStep(int step, String stepName) =>
      AnalyticsService().logEvent('tutorial_step', {
        'step': step,
        'step_name': stepName,
      });

  // Notification interaction
  static Future<void> notificationOpened(String notificationId) =>
      AnalyticsService().logEvent('notification_opened', {
        'notification_id': notificationId,
      });
}
