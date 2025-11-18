import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:task_app/task_model.dart';
// FIX 1: Replace the old import with the new, installed package
import 'package:flutter_timezone/flutter_timezone.dart'; 

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle notification tap
        if (kDebugMode) {
          print('notification payload: ${notificationResponse.payload}');
        }
      },
    );

    // Request notification permissions on Android 13+
    await _requestPermissions();

     await _configureLocalTimeZone();
  }

  Future<void> scheduleNotificationForTask(Task task) async {
    if (task.dueDateTime == null) return;

    // Ensure the due date is in the future
    if (task.dueDateTime!.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id, // Use task ID as notification ID
      'Task Due: ${task.title}',
      'Your task "${task.title}" is due now.',
      tz.TZDateTime.from(task.dueDateTime!, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_due_channel',
          'Task Due Dates',
          channelDescription: 'Notifications for when tasks are due.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // FIX 2: Replace FlutterNativeTimezone with the correct class: FlutterTimezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone(); 
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}