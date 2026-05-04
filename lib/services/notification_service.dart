import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const _channelId = 'impostor_cruceno_reminders';
  static const _channelName = 'Recordatorios de juego';
  static const _channelDescription = 'Notificaciones para recordar jugar Impostor Cruceño';

  static const _weeklyReminderId = 100;
  static const _engagementReminderId = 101;

  static const _reminderMessages = [
    '¿Noche de juegos? Llamá a tus amigos y jugá Impostor Cruceño! 🕵️',
    'El impostor está esperando... ¿Te animás a descubrirlo? 🎭',
    'Hoy es buen día para una partida de Impostor Cruceño, camba! 🎉',
    '¿Quién será el impostor esta noche? Juntate con tus amigos! 🤔',
    'Tus amigos ya están listos para jugar. ¿Vos también? 🎮',
  ];

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _isInitialized = true;
    debugPrint('[NotificationService] Inicializado correctamente');
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleWeeklyReminder({
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = _nextInstanceOfWeekdayTime(
      now, dayOfWeek, hour, minute);
    final messageIndex = now.millisecond % _reminderMessages.length;

    await _plugin.zonedSchedule(
      id: _weeklyReminderId,
      title: 'Impostor Cruceño',
      body: _reminderMessages[messageIndex],
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint('[NotificationService] Recordatorio semanal programado: '
        'día $dayOfWeek a las $hour:$minute');
  }

  Future<void> scheduleEngagementReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(days: 3));

    await _plugin.zonedSchedule(
      id: _engagementReminderId,
      title: 'Impostor Cruceño',
      body: '¡Hace rato no jugás! Tus amigos te extrañan en la partida 🎭',
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint('[NotificationService] Recordatorio de engagement en 3 días');
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
    debugPrint('[NotificationService] Todas las notificaciones canceladas');
  }

  Future<void> cancelWeeklyReminder() async {
    await _plugin.cancel(id: _weeklyReminderId);
  }

  Future<void> cancelEngagementReminder() async {
    await _plugin.cancel(id: _engagementReminderId);
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime(
    tz.TZDateTime now, int dayOfWeek, int hour, int minute,
  ) {
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != dayOfWeek || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
