import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Active in-memory timers for web fallback notifications
final Map<int, Timer> _webTimers = {};

/// Set this from the root widget so service can open dialogs
BuildContext? notificationContext;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  /// Schedules a notification. On Android/iOS it uses exact zonedSchedule.
  /// On Web (Chrome), it sets a Timer that fires a dialog at the exact moment.
  Future<void> scheduleSessionNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();
    final delay = scheduledTime.difference(now);

    if (delay.isNegative) {
      debugPrint('[Notification] Cannot schedule in the past: $scheduledTime');
      return;
    }

    if (kIsWeb) {
      // ✅ Web-compatible: Use a Timer that fires at the exact scheduled time
      _webTimers[id]?.cancel(); // Cancel existing if re-scheduling
      _webTimers[id] = Timer(delay, () {
        _showWebAlert(title, body);
      });
      debugPrint('[Notification] Web timer set for ${delay.inMinutes} min: $title');
      return;
    }

    // ✅ Native Android / iOS: Use exact timezone-based scheduling
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'study_sessions_channel',
      'Scheduled Study Sessions',
      channelDescription: 'Reminders for your specific study sessions',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Shows an alert dialog using the stored context (web fallback)
  void _showWebAlert(String title, String body) {
    final context = notificationContext;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_study_reminder_channel',
      'Study Reminders',
      channelDescription: 'Daily reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Test Reminder!',
      'This is your requested test reminder.',
      details,
    );
  }
}

