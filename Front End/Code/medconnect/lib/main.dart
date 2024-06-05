import 'package:flutter/material.dart';
import 'package:medconnect/dashboard.dart';
import 'package:medconnect/notifications.dart';
import 'package:medconnect/profile.dart';
import 'package:medconnect/register.dart';
import 'package:medconnect/login.dart';
import 'package:medconnect/search.dart';
import 'package:medconnect/logic.dart';
import 'package:medconnect/settings.dart';
import 'package:provider/provider.dart';
import 'package:medconnect/test.dart';
import 'package:medconnect/chat.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  debugPrint('handling a background message ${message.messageId}');
}

//Android Android notification channel for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', //id
    'High Importance Notifications', //title
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        )));
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TokenProvider()),
      Provider(create: (_) => TokenStorage()),
      ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      Provider(create: (_) => UserProfile())
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<String?> _getInitialRoute() async {
    String? token = await TokenStorage().getToken('jwtToken');
    return token != null ? '/Dashboard' : '/Login';
  }

  Future<void> _registerFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    debugPrint("FCM Token: $token");
    if (token != null){
      await _storeTokenLocally(token);
      sendTokenToServer(token);
    }

    //listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      await _storeTokenLocally(newToken);
      sendTokenToServer(newToken);
    });
  }

  Future<void> _storeTokenLocally(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
  }

  Future<void> sendTokenToServer(String token) async {
    await Dio().get('http://192.168.43.107:9000');
  }

  @override
  void initState() {
    super.initState();
    _registerFCM();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              darkTheme: ThemeData.dark(),
              theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true),
              initialRoute: snapshot.data ?? '/Login',
              title: 'MedConnect',
              routes: {
                '/Chat': (context) => const Chats(),
                '/Notification': (context) => const NotificationPage(),
                '/Register': (context) => const RegisterUser(),
                '/Login': (context) => const UserLogin(),
                '/Recruitment': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments;
                  if (args is String) {
                    return RecruitmentInfo(uniqueId: args);
                  }
                  return const Scaffold(body: Center(child: Text('Error')));
                },
                '/Contact': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments;
                  if (args is String) {
                    return ContactInfo(uniqueId: args);
                  }
                  return const Scaffold(body: Center(child: Text('Error')));
                },
                '/Account': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments;
                  if (args is String) {
                    return AccountInfo(uniqueId: args);
                  }
                  return const Scaffold(body: Center(child: Text('Error')));
                },
                '/Dashboard': (context) => const Home(),
                '/Profile': (context) => const Profile(),
                '/settings': (context) => const AppSettings(),
                '/Search': (context) => const Search(),
                '/Notifications': (context) => const Notifications(),
              },
            );
          }
        });
  }
}