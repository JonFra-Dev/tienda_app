import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Servicio de notificaciones locales (hardware nativo).
///
/// Soporta:
///   - Alertas inmediatas de presupuesto excedido
///   - Recordatorios programados de fechas de ingresos esperados
///   - Notificaciones de celebración al completar baby steps
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============== INIT ==============

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

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

  // ============== ALERTAS DE PRESUPUESTO ==============

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

  // ============== CELEBRACIONES DE BABY STEPS ==============

  /// Notificación push cuando el usuario completa un nuevo baby step.
  Future<void> showCelebration({
    required int stepNumber,
    required String stepName,
  }) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'celebration_channel',
      'Celebraciones de progreso',
      channelDescription:
          'Felicitaciones cuando completas un Baby Step de Dave Ramsey',
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.show(
        // ID negativo único para no chocar con otras notifs
        -1000 - stepNumber,
        '🎉 ¡Completaste Baby Step $stepNumber!',
        '$stepName — Sigue adelante, vas por buen camino 💪',
        details,
      );
    } catch (e) {
      debugPrint('showCelebration error: $e');
    }
  }

  // ============== RECORDATORIOS DE INGRESOS ==============

  static const int _incomeReminderIdBase = 1000000;

  int _idForSource(String sourceId) {
    return _incomeReminderIdBase + sourceId.hashCode.abs() % 1000000;
  }

  Future<void> scheduleIncomeReminder({
    required String sourceId,
    required String sourceName,
    required double expectedAmount,
    required DateTime nextExpectedDate,
  }) async {
    if (!_initialized) await init();

    await cancelIncomeReminder(sourceId);

    final reminderDate = nextExpectedDate.subtract(const Duration(days: 1));
    final scheduled = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );

    if (scheduled.isBefore(DateTime.now())) {
      debugPrint('scheduleIncomeReminder: fecha ya pasó, no se agenda');
      return;
    }

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'income_channel',
      'Recordatorios de ingresos',
      channelDescription:
          'Recuerda cuando vas a recibir tus ingresos recurrentes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        _idForSource(sourceId),
        'Mañana esperas tu ingreso',
        '$sourceName: \$${expectedAmount.toStringAsFixed(0)} aprox.',
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('scheduleIncomeReminder error: $e');
    }
  }

  Future<void> cancelIncomeReminder(String sourceId) async {
    if (!_initialized) await init();
    try {
      await _plugin.cancel(_idForSource(sourceId));
    } catch (e) {
      debugPrint('cancelIncomeReminder error: $e');
    }
  }

  Future<void> cancelAllIncomeReminders() async {
    if (!_initialized) await init();
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final p in pending) {
        if (p.id >= _incomeReminderIdBase &&
            p.id < _incomeReminderIdBase + 1000000) {
          await _plugin.cancel(p.id);
        }
      }
    } catch (e) {
      debugPrint('cancelAllIncomeReminders error: $e');
    }
  }
}
