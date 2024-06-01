import 'package:flutter/material.dart';
import 'package:medconnect/chat.dart';
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

void main() {
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      initialRoute: '/Register',
      title: 'MedConnect',
      routes: {
        '/ChatRoom': (context) => const ChatRoom(),
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
        '/Dashboard': (context) => const Dashboard(),
        '/Profile': (context) => const Profile(),
        '/Chat': (context) => const Chat(),
        '/settings': (context) => const AppSettings(),
        '/Search': (context) => const Search(),
        '/Notifications': (context) => const Notifications(),
      },
    );
  }
}