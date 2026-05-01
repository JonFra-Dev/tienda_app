import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio de notificaciones locales (hardware nativo).
///
/// Cumple con el requisito de "al menos una funcionalidad de hardware nativo".
/// Se usa para alertas cuando el presupuesto mensual se está agotando.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();

      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('requestPermissions error: $e');
    }
  }

  Future<void> showBudgetAlert({
    required double percentUsed,
    required double remaining,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      'Alertas de presupuesto',
      channelDescription: 'Notifica cuando el presupuesto mensual se agota',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final title = percentUsed >= 100
        ? '¡Presupuesto excedido!'
        : 'Presupuesto al ${percentUsed.toStringAsFixed(0)}%';
    final body = percentUsed >= 100
        ? 'Has superado tu presupuesto mensual.'
        : 'Te quedan \$${remaining.toStringAsFixed(2)} este mes.';

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
      );
    } catch (e) {
      debugPrint('showBudgetAlert error: $e');
    }
  }
}
