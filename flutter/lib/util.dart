import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

const String serverUrl = 'ai-tracker-server-613e3dd103bb.herokuapp.com';
// String serverUrl = 'localhost:3000'; // Change localhost to the appropriate IP if needed

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> convertMessageToEvent(String query) async {
  const String url =
      // 'http://localhost:3000/convertMessageToEvent'; // Change localhost to the appropriate IP if needed
      'http://$serverUrl/convertMessageToEvent';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query, 'time': getTime()}),
  );

  if (response.statusCode == 200) {
    print('Server responded with: ${response.body}');
  } else {
    print('Failed to load data: ${response.statusCode}');
  }
}

String getTime() {
  DateTime now = DateTime.now();
  String offsetSign = now.timeZoneOffset.isNegative ? "-" : "+";
  int offsetHours = now.timeZoneOffset.inHours.abs();
  int offsetMinutes = now.timeZoneOffset.inMinutes.abs() % 60;
  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0');
  String day = now.day.toString().padLeft(2, '0');
  int hour24 = now.hour;
  String hours =
      (hour24 % 12 == 0 ? 12 : hour24 % 12).toString().padLeft(2, '0');
  String minutes = now.minute.toString().padLeft(2, '0');
  String seconds = now.second.toString().padLeft(2, '0');
  String ampm = hour24 >= 12 ? 'PM' : 'AM';
  String formattedDateTimeWithTimeZone =
      "$year-$month-$day, $hours:$minutes:$seconds $ampm $offsetSign${offsetHours.toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}";
  return formattedDateTimeWithTimeZone;
}

void scheduleHourlyNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('repeating channel id',
          'repeating channel name', 'repeating description');
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: IOSNotificationDetails(
        sound: 'slow_spring_board.aiff',
        presentAlert: true,
        presentBadge: true,
      ),
      android: androidPlatformChannelSpecifics);
  try {
    print("scheduling notification");
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Log Reminder',
        'Time to log your progress',
        RepeatInterval.hourly,
        platformChannelSpecifics);
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}

void scheduleNotification() async {
  // tz.TZDateTime scheduledNotificationDateTime =
  //     tz.TZDateTime.now(tz.local).add(Duration(seconds: 15));

  // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //   'channel id 2',
  //   'channel name 2',
  //   'channel description 2',
  // );

  // var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  // var platformChannelSpecifics = NotificationDetails(
  //   android: androidPlatformChannelSpecifics,
  //   iOS: iOSPlatformChannelSpecifics,
  // );

  // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   DateTime.now().millisecondsSinceEpoch % 1000000,
  //   'scheduled title',
  //   'scheduled body',
  //   scheduledNotificationDateTime,
  //   platformChannelSpecifics,
  //   androidAllowWhileIdle: true,
  //   uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime,
  //   matchDateTimeComponents: DateTimeComponents.time,
  // );
}

void startNotification() {
  tz.initializeTimeZones();
  scheduleHourlyNotification();
  // onSelectNotification: (String? payload) async => scheduleNotification());
  scheduleNotification();
}

void initNotifications() {
  InitializationSettings initializationSettings = const InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    iOS: IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    ),
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
