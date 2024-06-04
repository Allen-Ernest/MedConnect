import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medconnect/logic.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> with Logic {
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String password = '';
  String jwtToken = '';
  bool _isPasswordVisible = false;
  late TokenStorage tokenStorage;
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    tokenStorage = Provider.of<TokenStorage>(context, listen: false);
    userProfile = Provider.of<UserProfile>(context, listen: false);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Response response = await Dio().get('http://192.168.43.108:9000/');
        if (response.statusCode == 200) {
          Response response2 = await Dio().post(
              'http://192.168.43.108:9000/login',
              data: {'username': userName, 'password': password});
          jwtToken = response2.data['token'];
          await tokenStorage.saveToken('jwtToken', jwtToken);
          if (context.mounted) {
            ApiService apiService = ApiService();
            Map<String, dynamic> userInfo =
                await apiService.fetchProfileInfo(jwtToken);
            await userProfile.saveUserProfile(userInfo);
            Navigator.pushNamed(context, '/Profile');
          }
        }
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection error'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: loginUser,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Insert your User Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      userName = value!;
                    },
                    decoration: const InputDecoration(
                        hintText: 'User Name',
                        labelText: 'User Name',
                        icon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true
                    )),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert your Password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      password = value!;
                    });
                  },
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                      hintText: 'Password',
                      icon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: _togglePasswordVisibility,
                      )),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () {
                      loginUser();
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            const Size(350, double.infinity))),
                    child: const Text('Sign in')),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: const Text('Have no Account? Register Now'))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
