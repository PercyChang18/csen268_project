import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // ask for user's permission
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Uses the default app icon

    // Initialization settings for iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone data
    tz.initializeTimeZones();
  }

  /// Schedules a daily notification at the specified time.
  Future<void> scheduleDailyWorkoutReminder(TimeOfDay time) async {
    // Cancel any previously scheduled reminders to prevent duplicates
    await flutterLocalNotificationsPlugin.cancel(0);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time for today is in the past, schedule it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Time for your workout!', // Notification title
      'Don\'t forget to complete your workout for today.', // Notification body
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_workout_reminder_channel',
          'Daily Workout Reminders',
          channelDescription:
              'Channel for daily workout reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // This makes the notification repeat daily at the specified time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
