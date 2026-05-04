import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Servicio de notificaciones locales (hardware nativo).
///
/// Cumple con el requisito de "al menos una funcionalidad de hardware nativo".
/// Soporta:
///   - Alertas inmediatas de presupuesto excedido
///   - Recordatorios programados de fechas de ingresos esperados
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============== INIT ==============

  Future<void> init() async {
    if (_initialized) return;

    // Inicializar timezones (necesario para notificaciones programadas)
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

  // ============== RECORDATORIOS DE INGRESOS ==============

  /// IDs reservados para recordatorios de ingresos (evita choque con otros).
  static const int _incomeReminderIdBase = 1000000;

  /// Convierte un sourceId (string) a un int único pero estable.
  int _idForSource(String sourceId) {
    return _incomeReminderIdBase + sourceId.hashCode.abs() % 1000000;
  }

  /// Programa un recordatorio para 1 día antes de la fecha esperada,
  /// a las 9 AM hora local. Si la fecha ya pasó, no agenda nada.
  Future<void> scheduleIncomeReminder({
    required String sourceId,
    required String sourceName,
    required double expectedAmount,
    required DateTime nextExpectedDate,
  }) async {
    if (!_initialized) await init();

    // Cancelar el anterior por si existía
    await cancelIncomeReminder(sourceId);

    // Notificar 1 día antes a las 9 AM
    final reminderDate = nextExpectedDate.subtract(const Duration(days: 1));
    final scheduled = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9, // 9 AM
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
        matchDateTimeComponents: null, // una sola vez
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

  /// Cancela todos los recordatorios de ingresos pendientes.
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
