//import 'dart:convert';
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

//import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime lastActive;
  final bool isOnline;

  const UserModel(
      {required this.name,
      required this.image,
      required this.lastActive,
      required this.email,
      required this.uid,
      this.isOnline = false});
}

class UserItem extends StatefulWidget {
  const UserItem({super.key, required this.user});

  final UserModel user;

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Stack(alignment: Alignment.bottomRight, children: [
          CircleAvatar(
              radius: 30, backgroundImage: NetworkImage(widget.user.image)),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CircleAvatar(
                backgroundColor:
                    widget.user.isOnline ? Colors.green : Colors.grey,
                radius: 5),
          )
        ]),
        title: Text(widget.user.name,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        subtitle: Text('last Active ${widget.user.lastActive.toString()}',
            //Use time ago instead if the contact was online within the last 24 hours otherwise use actual time in eg 10/23/2024 at 9:24pm
            maxLines: 2,
            style: const TextStyle(
                color: Colors.purple,
                fontSize: 15,
                overflow: TextOverflow.ellipsis)));
  }
}

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  int _selectedIndex = 3;

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

  final userList = [
    UserModel(
        uid: '1',
        name: 'Heisenberg',
        email: 'sample@sample.com',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Bundesarchiv_Bild183-R57262%2C_Werner_Heisenberg.jpg/285px-Bundesarchiv_Bild183-R57262%2C_Werner_Heisenberg.jpg',
        isOnline: false,
        lastActive: DateTime.now()),
    UserModel(
        uid: '1',
        name: 'Tyson',
        email: 'sample@sample.com',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Mike_Tyson_Photo_Op_GalaxyCon_Austin_2023.jpg/330px-Mike_Tyson_Photo_Op_GalaxyCon_Austin_2023.jpg',
        isOnline: false,
        lastActive: DateTime.now()),
    UserModel(
        uid: '2',
        name: 'Bruce',
        email: 'sample@sample.com',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Bruce_Willis_by_Gage_Skidmore_3.jpg/330px-Bruce_Willis_by_Gage_Skidmore_3.jpg',
        isOnline: true,
        lastActive: DateTime.now()),
    UserModel(
        uid: '3',
        name: 'Escobar',
        email: 'sample@sample.com',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Pablo_Escobar_Mug.jpg/330px-Pablo_Escobar_Mug.jpg',
        isOnline: true,
        lastActive: DateTime.now())
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Chats'),
            actions: <Widget>[
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.search_rounded))
            ],
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.groups)),
            ])),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(children: <Widget>[
              const Tab(child: Text('Messaged chats will appear here')),
              Tab(
                  child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) =>
                    UserItem(user: userList[index]),
              )),
            ])),
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
  final List<types.Message> _messages = [];
  final _user = const types.User(
    id: '123',
  );
  final _otherUser = const types.User(
    id: '456', // Other user
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) => SafeArea(
            child: SizedBox(
                height: 144,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleImageSelection();
                        },
                        child: const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('Photo'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleFileSelection();
                        },
                        child: const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('File'),
                        ),
                      ),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text('Cancel'),
                          ))
                    ]))));
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
        imageQuality: 100, source: ImageSource.gallery, maxWidth: 1440);
    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: image.height.toDouble(),
          id: const Uuid().v4(),
          name: result.name,
          size: bytes.length,
          uri: result.path,
          width: image.width.toDouble());
      _addMessage(message);
    }
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);
  }

  void _handleReceivedMessage() {
    final textMessage = types.TextMessage(
      author: _otherUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "This is a received message.",
    );
    _addMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  onAttachmentPressed: _handleAttachmentPressed,
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _user,
                  isLeftStatus: true),
            ),
            TextButton(
              onPressed: _handleReceivedMessage,
              child: const Text("Simulate Received Message"),
            ),
          ],
        ),
      ),
    );
  }
}
