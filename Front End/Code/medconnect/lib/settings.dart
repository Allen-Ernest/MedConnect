import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> with Logic {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView(
          children: [
            const Text('Account Settings'),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('Account Info'),
              onTap: (){},
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_alt_1_rounded),
              title: const Text('Deactivate Acount'),
              onTap: (){},
            ),
            ListTile(
              leading: const Icon(Icons.person_off_rounded),
              title: const Text('Delete Account'),
              onTap: (){},
            ),
            const Text('App Settings'),
            ListTile(
              leading: const Icon(Icons.settings_accessibility_rounded),
              title: const Text('Accessibility'),
              onTap: (){},
            ),
            ListTile(
              leading: const Icon(Icons.data_usage_rounded),
              title: const Text('Data Usage'),
              onTap: (){},
            ),
          ],
        ),
      ),
    );
  }
}
