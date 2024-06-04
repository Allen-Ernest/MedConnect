import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_widget/flutter_chat_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:medconnect/logic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int _selectedIndex = 3;
  Map<int, Color> tileColors = {};

  void toggleHighlightedTileColor(index) {
    setState(() {
      if (tileColors[index] != Colors.red) {
        tileColors[index] = Colors.red;
      } else {
        tileColors[index] = Colors.white;
      }
    });
  }

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
      appBar: AppBar(title: const Text('Chats'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemBuilder: (context, index) => GestureDetector(
                  onLongPress: () {
                    toggleHighlightedTileColor(index);
                  },
                  child: ListTile(
                    tileColor: tileColors[index] ?? Colors.white,
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/Albert.jpg'),
                    ),
                    title: const Text('Allen Ernest'),
                    subtitle: const Text(
                      'Erythroblastosis Fetalis complications are said to have affected 47% of children born in Africa',
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(DateTime.now().toString()),
                    onTap: () {
                      Navigator.pushNamed(context, '/ChatRoom');
                    },
                  ),
                )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.feed_rounded), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_off_rounded), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_rounded),
              label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded), label: 'Chats')
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  List<Map<String, dynamic>> messages = [];
  String? userId;
  String? recipientId;
  String? token;
  late TokenStorage tokenStorage;
  late IO.Socket socket;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> loadToken() async {
    token = await TokenStorage().getToken('jwtToken');
    setState(() {});
  }

  Future loadUserName() async {
    Map<String, dynamic> profile = await UserProfile().getUserProfile();
    setState(() {
      userId = profile['username'];
      recipientId = profile['username'];
    });
    connectSocket();
  }

  void connectSocket() {
    socket = IO.io(
        'http://192.168.43.108:9000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setQuery({'userId': userId})
            .build());
    socket.connect();
    setUpSocketListener();
  }

  sendMessage(String text) {
    var messageJson = {
      'message': text,
      'senderId': socket.id,
      'recipientId': recipientId,
      'id': socket.id,
    };
    socket.emit('message', messageJson);
    setState(() {
      messages.add(messageJson);
    });
  }

  setUpSocketListener() {
    socket.on('message-received', (data) {
      debugPrint('Message received: $data');
      setState(() {
        messages.add(data);
      });
      _showNotification(data['message']);
    });
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics  = AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max, priority: Priority.high, showWhen: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Message', message, platformChannelSpecifics
    );
  }

  @override
  void initState() {
    super.initState();
    loadToken();
    loadUserName();
    tokenStorage = Provider.of<TokenStorage>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(children: <Widget>[
        const CircleAvatar(backgroundImage: AssetImage('assets/doctor1.jpg')),
        Text(userId ?? 'Unknown')
      ])),
      body: Column(children: <Widget>[
        Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isSentByMe = message['id'] == socket.id;
                return isSentByMe
                    ? SentMessage(
                        message: message['message'],
                        background: Colors.deepPurple,
                        textColor: Colors.white,
                      )
                    : ReceivedMessage(
                        message: message['message'],
                        background: Colors.black12,
                        textColor: Colors.black,
                      );
              },
            )),
        Expanded(child: MessageBar(onCLicked: (text) {
          sendMessage(text);
        }))
      ]),
    );
  }
}
