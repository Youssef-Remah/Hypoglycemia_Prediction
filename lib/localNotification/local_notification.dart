import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class localNotification {
  // Example of a long vibration pattern

  static final FlutterLocalNotificationsPlugin
  _FlutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await checkPermissions();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      // onDidReceiveLocalNotification: (id, title, body, payload) => null
    );
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    _FlutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Simple Notification
  Future<void> showNotification(
      {required String title,
        required String body,
        required String payload}) async {
    var vibrationPattern =
    Int64List.fromList([0, 2000]); // Wait 0ms, Vibrate 1000ms

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('local1', 'hypoEvent',
        channelDescription: 'your channel description1',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        fullScreenIntent: true,
        vibrationPattern: vibrationPattern,
        enableVibration: true,
        ticker: 'ticker1');

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _FlutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails,
        payload: payload);
  }

// Periodic notification
  Future<void> showPeriodicNotification(
      {required String title,
        required String body,
        required String payload}) async {
    var vibrationPattern =
    Int64List.fromList([0, 2000]); // Wait 0ms, Vibrate 1000ms

    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('hypo_NOTIFICATION', 'Check Glucose Level',
        channelDescription: 'repeated alert for the users',
        importance: Importance.max,
        priority: Priority.high,
        vibrationPattern: vibrationPattern,
        ticker: 'hypo_NOTIFICATION');

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    try {
      await _FlutterLocalNotificationsPlugin.periodicallyShow(
        001,
        title,
        body,
        RepeatInterval.everyMinute,
        notificationDetails,
      );
      print('Periodic notification scheduled: $title');
    } catch (e) {
      print('Error scheduling periodic notification: $e');
    }
  }

  // Scheduled Notification
  Future scheduledNotify(
      {required String title,
        required String body,
        required String payload}) async {
    tz.initializeTimeZones();
    await _FlutterLocalNotificationsPlugin.zonedSchedule(
        02,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('local3', 'Scheduled Notification',
                channelDescription: 'your channel description3',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker3')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  void closeNotification(int id) async {
    await _FlutterLocalNotificationsPlugin.cancel(id);
  }

  void cancelAll() async {
    await _FlutterLocalNotificationsPlugin.cancelAll();
  }
}
