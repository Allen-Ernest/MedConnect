import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initializeNotifications() async {
    //Initialize settings for notifications channels
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    //Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  @override
  void initState(){
    super.initState();
    initializeNotifications();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            //Define notification details
            const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'channel_id', 'chanel_name', importance: Importance.max, priority: Priority.high, showWhen: true
            );
            const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
            
            //Show notification
            await flutterLocalNotificationsPlugin.show(0, 'Sample Notification', 'this is the body of the notification', platformChannelSpecifics);
          },
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}
