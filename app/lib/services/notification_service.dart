import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _streakChannelId = 'streak_reminder';
  static const _streakNotificationId = 0;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await android?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Schedule the daily streak reminder at 19:00 local time.
  Future<void> scheduleStreakReminder() async {
    await cancelStreakReminder();

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, 19, 0);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    // Convert to TZDateTime using UTC offset
    final scheduledDate = tz.TZDateTime.from(target, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _streakChannelId,
      'Streak Reminder',
      channelDescription: 'Daily reminder to maintain your study streak',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _streakNotificationId,
      '\u{1F525} Don\'t break your streak!',
      'Your daily challenge is waiting.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel and reschedule for tomorrow (called when user studies today).
  Future<void> onUserStudied() async {
    await cancelStreakReminder();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final target = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 19, 0);
    final scheduledDate = tz.TZDateTime.from(target, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _streakChannelId,
      'Streak Reminder',
      channelDescription: 'Daily reminder to maintain your study streak',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _streakNotificationId,
      '\u{1F525} Don\'t break your streak!',
      'Your daily challenge is waiting.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelStreakReminder() async {
    await _plugin.cancel(_streakNotificationId);
  }
}
