import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with Logic {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              )
            : const Text('Search Page'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      drawer: Drawer(
        backgroundColor: bgColor,
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
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
              const Text(
                'Opthamologist',
                style: TextStyle(fontSize: 16, color: Colors.white),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
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
      ),
    );
  }
}
