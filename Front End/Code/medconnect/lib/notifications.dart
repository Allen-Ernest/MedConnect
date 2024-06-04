import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with Logic {
  String? token;
  late TokenStorage tokenStorage;
  String? username;
  String? password;

  Future<void> loadToken() async {
    token = await TokenStorage().getToken('jwtToken');
    setState(() {});
  }

  Future loadUserName() async {
    Map<String, dynamic> profile = await UserProfile().getUserProfile();
    username = profile['username'];
    password = profile['password'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadToken();
    tokenStorage = Provider.of<TokenStorage>(context, listen: false);
  }

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/Dashboard');
          break;
        case 1:
          Navigator.pushNamed(context, '/Search');
          break;
        case 2:
          Navigator.pushNamed(context, '/Notifications');
          break;
        case 3:
          Navigator.pushNamed(context, '/Chat');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MedConnect'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.logout_rounded))
          ],
        ),
        drawer: Drawer(
          child: ListView(children: <Widget>[
            DrawerHeader(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Profile');
                      },
                      child: const CircleAvatar(
                          radius: 40.0,
                          backgroundImage: AssetImage('assets/doctor1.jpg')),
                    ),
                    const Text(
                      'Allen Ernest',
                      style: TextStyle(fontSize: 28),
                    ),
                    const Expanded(
                      child: Text(
                        'Ophthalmologist',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                )),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.bookmark_rounded),
              title: const Text('Bookmarks'),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.help_rounded),
              title: const Text('Help and Support'),
            ),
          ]),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(username ?? 'Unknown'),
                Text(password ?? 'Password'),
                TextButton(
                    onPressed: () {
                      loadUserName();
                    },
                    child: const Text('load User name'))
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.feed_rounded), label: 'Feed'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_rounded),
                label: 'Notifications'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded), label: 'Chats')
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.red,
        ));
  }
}
