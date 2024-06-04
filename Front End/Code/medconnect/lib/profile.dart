import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with Logic {
  String? token;
  String userName = '';
  String email = '';
  String useroccupation = "";
  String institution = '';
  String license = '';
  String district = '';
  String city = '';
  late TokenStorage tokenStorage;

  Future logout() async {
    await tokenStorage.deleteToken('jwtToken');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/Login');
    }
    return const SnackBar(content: Text('Logged Out'));
  }

  Future fetchProfileData() async {
    try {
      Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
      Response response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        )
      ).get('http://192.168.43.108:9000');
      if (response.statusCode == 200) {
        Response response2 = await Dio().post(
            'http://192.168.43.108:9000/registerUser/profile',
            options: Options(headers: headers));
        Map<String, dynamic> userData = response2.data;
        setState(() {
          userName = userData['Username'];
          email = userData['Email'];
          useroccupation = userData['Occupation'];
          institution = userData['Institution'];
          license = userData['LICENSE'];
          district = userData['District'];
          city = userData['Region'];
        });
      }
    } on DioException catch (error) {
      debugPrint('Request time out');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connection error'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: fetchProfileData,
          ),
        ),
      );
    }
  }

  Future<void> loadToken() async {
    token = await TokenStorage().getToken('jwtToken');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    loadToken();
    tokenStorage = Provider.of<TokenStorage>(context, listen: false);
  }

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MedConnect'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(onPressed: logout, icon: const Icon(Icons.logout))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  GestureDetector(
                    onTap: (){},
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/Albert.jpg'),
                    ),
                  ),
                  const Text('Allen Ernest')
                ],
              ),
              Text(token ?? 'Waiting for Token'),
              ElevatedButton(
                  onPressed: () {
                    fetchProfileData();
                  },
                  child: const Text('test headers')),
              Text(userName),
              Text(email),
              Text(useroccupation),
              Text(license),
              Text(district),
              Text(city),
              Text(institution),
            ],
          ),
        )
      ),
    );
  }
}
