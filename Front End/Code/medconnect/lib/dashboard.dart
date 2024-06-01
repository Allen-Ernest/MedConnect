import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';
import 'package:dio/dio.dart';
//import 'package:web_socket_client/web_socket_client.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with Logic {
  bool isLiked = false;
  int _selectedIndex = 0;

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

  String? token; //Modify the token to be stored globally within the app
  String? username;
  String? email;
  String? useroccupation;
  late TokenStorage tokenStorage;

  Future fetchProfileInfo(token) async {
    try {
      Response response = await Dio().get('http://192.168.43.108:9000');
      if (response.statusCode == 200) {
        Response response2 = await Dio()
            .get('http:192.168.43.108:9000/registerUser/profile', data: {
          'token': token, //Modify it to contain the actual token
        });
        username = response2.data.username;
        useroccupation = response2.data.occupation;
        email = response2.data.email;
      }
    } on DioException catch (error) {
      return AlertDialog(
        content: Column(
          children: [
            const Icon(Icons.warning_rounded),
            Text(error.message.toString())
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                fetchProfileInfo(token);
              },
              icon: const Icon(Icons.refresh_rounded)),
          IconButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.cancel_rounded))
        ],
      );
    }
  }

  Future logout() async {
    await tokenStorage.deleteToken('jwtToken');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/Login');
    }
    return const SnackBar(content: Text('Logged Out'));
  }

  Future loadFeed() async {
    Response response;
    response = await Dio().get('http://192.168.43.107:9000/posts');
    if (response.statusCode == 200) {
      // TODO: fetch posts from server
    }
  }

  fetchComments() => {
        debugPrint('Comments are being fetched'),
        showModalBottomSheet(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            context: context,
            builder: ((context) => ListView(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/Albert.jpg'),
                      ),
                      title: const Text('Albert Joshua'),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Comment will displayed here'),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.reply_rounded)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.report_rounded))
                              ],
                            )
                          ]),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/Albert.jpg'),
                      ),
                      title: const Text('Allen Ernest'),
                      subtitle: Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Another Comment will displayed here'),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.reply_rounded)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.report_rounded))
                                ],
                              )
                            ]),
                      ),
                    ),
                  ],
                )))
      };

  postActions(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: ((context) => Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(5),
                      topEnd: Radius.circular(5))),
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.reply_rounded),
                    title: const Text('Reply Privately'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.report_rounded),
                    title: const Text('Report Post'),
                    onTap: () {},
                  )
                ],
              ),
            )));
  }

  Future<void> loadToken() async {
    token = await TokenStorage().getToken('jwtToken');
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadToken();
    //loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medconnect'), //Style the title text
        centerTitle: true,
        actions: [
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
      body: RefreshIndicator(
        onRefresh: loadFeed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CircleAvatar(
                  backgroundImage: AssetImage('assets/doctor1.jpg')),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Richard Thompson',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text(
                        'The app is currently under construction, and it will be published within 30 days, thanks for your patience'),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child:
                            const Image(image: AssetImage('assets/doctor1.jpg'))),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildInteractionIcon(
                              iconData: isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              text: '387',
                              onTap: () => setState(
                                    () => isLiked = !isLiked,
                                  )),
                          buildInteractionIcon(
                              iconData: Icons.chat_bubble_outline,
                              text: '8',
                              onTap: () {
                                fetchComments();
                              }),
                          buildInteractionIcon(
                              iconData: Icons.repeat,
                              text: '32',
                              onTap: () => debugPrint('Open Retweet Section'))
                        ]),
                  ]))
            ]),
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
      ),
    );
  }
}

Widget buildInteractionIcon({
  required IconData iconData,
  required String text,
  required Function onTap,
}) {
  return InkWell(
      onTap: () => onTap(),
      child: Row(
        children: [
          Icon(iconData),
          Text(
            text,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ));
}
