import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class ReminderNotifications {
  ReminderNotifications._();

  static const _notificationId = 207;
  static const _channelId = 'daily_quran_reminder';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void>? _initialization;

  static Future<void> _initialize() {
    return _initialization ??= _initializePlugin();
  }

  static Future<void> _initializePlugin() async {
    timezone_data.initializeTimeZones();
    if (Platform.isAndroid || Platform.isIOS) {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  static Future<void> scheduleDaily(int minuteOfDay) async {
    await _initialize();
    final now = timezone.TZDateTime.now(timezone.local);
    var scheduled = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      minuteOfDay ~/ 60,
      minuteOfDay % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'A moment with the Quran',
      body: 'Take a quiet moment for your daily Quran reading.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily Quran reminder',
          channelDescription: 'A daily reminder to read the Quran.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel() async {
    await _initialize();
    await _plugin.cancel(id: _notificationId);
  }
}
