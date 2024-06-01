import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

mixin Logic {
  double padding = 15.0;
  String? uniqueId;
  String path = 'http://192.168.43.108:9000';

  /*Decoration formDecoration = InputDecoration(
    border: InputBorder
  );*/
  final Color bgColor = const Color(0xFF002A4A);

  List<DropdownMenuItem<String>> occupation = [
    const DropdownMenuItem(
        value: 'Medical Doctor (General)',
        child: Text('Medical Doctor (General)')),
    const DropdownMenuItem(
        value: 'Medical Doctor (Surgeon)',
        child: Text('Medical Doctor (Surgeon)')),
    const DropdownMenuItem(value: 'Cardiologist', child: Text('Cardiologist')),
    const DropdownMenuItem(
        value: 'Clinical Officer', child: Text('Clinical Officer')),
    const DropdownMenuItem(value: 'Dentist', child: Text('Dentist')),
    const DropdownMenuItem(
        value: 'Dermatologist', child: Text('Dermatologist')),
    const DropdownMenuItem(
        value: 'Medical Labaratory Technician',
        child: Text('Medical labaratory Technician')),
    const DropdownMenuItem(value: 'Neurologist', child: Text('Neurologist')),
    const DropdownMenuItem(value: 'Nurse', child: Text('Nurse')),
    const DropdownMenuItem(
        value: 'Ophthalmologist', child: Text('Opthalmologist')),
    const DropdownMenuItem(value: 'Optician', child: Text('Optician')),
    const DropdownMenuItem(value: 'Orthopedist', child: Text('Orthopedist')),
    const DropdownMenuItem(
        value: 'Paediatrician', child: Text('Paediatrician')),
    const DropdownMenuItem(value: 'Pharmacist', child: Text('Pharmacist')),
    const DropdownMenuItem(
        value: 'Physiotherapist', child: Text('Physiotherapist')),
    const DropdownMenuItem(value: 'Radiologist', child: Text('Radiologist')),
  ];
  List<DropdownMenuItem<String>> region = [
    const DropdownMenuItem(value: 'Arusha', child: Text('Arusha')),
    const DropdownMenuItem(
        value: 'Dar es Salaam', child: Text('Dar es Salaam')),
    const DropdownMenuItem(value: 'Dodoma', child: Text('Dodoma')),
    const DropdownMenuItem(value: 'Geita', child: Text('Geita')),
    const DropdownMenuItem(value: 'Iringa', child: Text('Iringa')),
    const DropdownMenuItem(value: 'Kagera', child: Text('Kagera')),
    const DropdownMenuItem(value: 'Katavi', child: Text('Katavi')),
    const DropdownMenuItem(value: 'Kigoma', child: Text('Kigoma')),
    const DropdownMenuItem(value: 'Kilimanjaro', child: Text('Kilimanjaro')),
    const DropdownMenuItem(value: 'Lindi', child: Text('Lindi')),
    const DropdownMenuItem(value: 'Manyara', child: Text('Manyara')),
    const DropdownMenuItem(value: 'Mara', child: Text('Mara')),
    const DropdownMenuItem(value: 'Mbeya', child: Text('Mbeya')),
    const DropdownMenuItem(value: 'Morogoro', child: Text('Morogoro')),
    const DropdownMenuItem(value: 'Mtwara', child: Text('Mtwara')),
    const DropdownMenuItem(value: 'Mwanza', child: Text('Mwanza')),
    const DropdownMenuItem(value: 'Njombe', child: Text('Njombe')),
    const DropdownMenuItem(
        value: 'Pemba kaskazini', child: Text('Pemba Kaskazini')),
    const DropdownMenuItem(value: 'Pemba Kusini', child: Text('Pemba Kusini')),
    const DropdownMenuItem(value: 'Pwani', child: Text('Pwani')),
    const DropdownMenuItem(value: 'Rukwa', child: Text('Rukwa')),
    const DropdownMenuItem(value: 'Ruvuma', child: Text('Ruvuma')),
    const DropdownMenuItem(value: 'Shinyanga', child: Text('Shinyanga')),
    const DropdownMenuItem(value: 'Simiyu', child: Text('Simiyu')),
    const DropdownMenuItem(value: 'Singida', child: Text('Singida')),
    const DropdownMenuItem(value: 'Songwe', child: Text('Songwe')),
    const DropdownMenuItem(value: 'Tabora', child: Text('Tabora')),
    const DropdownMenuItem(value: 'Tanga', child: Text('Tanga')),
    const DropdownMenuItem(
        value: 'Unguja Kaskazini', child: Text('Unguja Kaskazini')),
    const DropdownMenuItem(
        value: 'Unguja Kusini', child: Text('Unguja Kusini')),
    const DropdownMenuItem(
        value: 'Unguja Mjini Magharibi', child: Text('Unguja Mjini Magharibi')),
  ];

  Map<String, List<String>> districts = {
    'Arusha': [
      'Arusha Urburn',
      'Arusha Rural',
      'Karatu',
      'Loliondo',
      'Meru',
      'Monduli',
      'Ngorongoro'
    ],
    'Dar es Salaam': ['Ilala', 'Kigamboni', 'Kinondoni', 'Temeke', 'Ubungo'],
    'Dodoma': [
      'Bahi',
      'Chamwino',
      'Chemba',
      'Dodoma Municipal',
      'Kondoa',
      'Kongwa',
      'Mpwapwa'
    ],
    'Geita': [
      'Bukombe',
      'Chato',
      'Geita rural',
      'Geita Urban',
      'Mbogwe',
      "Nyang'hwale"
    ],
    'Iringa': [
      'Iringa Rural',
      'Iringa Urban',
      'Kilolo',
      'Mafinga Town',
      'Mufindi',
    ],
    'Kagera': [
      'Biharamulo',
      'Bukoba Rural',
      'Bukoba Urban',
      'Karagwe',
      'Kyerwa',
      'Muleba',
      'Ngara'
    ],
    'Katavi': ['Mlele', 'Mpanda', 'Tanganyika'],
    'Kigoma': ['Buhigwe', 'Kakonko', 'Kasulu', 'Kibondo', 'Ujiji', 'Uvinza'],
    'Kilimanjaro': [
      'Hai',
      'Moshi Rural',
      'Moshi Urban',
      'Mwanga',
      'Rombo',
      'Same',
      'Siha'
    ],
    'Lindi': [
      'Lindi rural',
      'Lindi Urban',
      'Liwale',
      'Kilwa',
      'Nachingwea',
      'Ruangwa'
    ],
    'Manyara': [
      'Babati rural',
      'Babati Urban',
      'Hanang',
      'Mbulu Rural',
      'Mbulu Urban',
      'Kiteto',
      'Simanjiro'
    ],
    'Mara': [
      'Bunda',
      'Butima',
      'Musoma Rural',
      'Musoma Urban',
      'Rorya',
      'Serengeti',
      'Tarime'
    ],
    'Mbeya': ['Busokelo', 'Chunya', 'Kyela', 'Mbarali', 'Mbeya', 'Rungwe'],
    'Morogoro': [
      'Gairo',
      'Ifakara',
      'Kilombero',
      'Kilosa',
      'Malinyi',
      'Morogoro Rural',
      'Morogoro Urban',
      'Mvomero',
      'Ulanga'
    ],
    'Mtwara': [
      'Masasi Town',
      'Masasi District',
      'Mikindani',
      'Mtwara',
      'Nanyamba Town',
      'Nanyumbu',
      'Newala Town',
      'Newala',
      'Tandahimba'
    ],
    'Mwanza': [
      'Buchosa',
      'Ilemela',
      'Kwimba',
      'Magu',
      'Misungwi',
      'Nyamagana',
      'Sengerema',
      'Ukerewe'
    ],
    'Njombe': [
      'Ludewa',
      'Makambako',
      'Makete',
      'Njombe Rural',
      'Njombe Town',
      "Wanging'ombe"
    ],
    'Pemba Kaskazini': ['Michweni', 'Wete'],
    'Pemba Kusini': ['Chake Chake', 'Mkoani'],
    'Pwani': [
      'Bagamoyo',
      'Chalinze',
      'Kibaha Rural',
      'Kibaha urban',
      'Kisarawe',
      'Kibiti',
      'Mkuranga',
      'Mafia',
      'Rufiji'
    ],
    'Rukwa': ['Kalambo', 'Nkasi', 'Sumbawanga Rural', 'Sumbawanga Urban'],
    'Ruvuma': [
      'Madaba',
      'Mbinga Rural',
      'Mbinga Urban',
      'Namtumbo',
      'Nyasa',
      'Songea Urban',
      'Songea Rural',
      'Tuduru'
    ],
    'Shinyanga': [
      'Kahama Urban',
      'Kahama Rural',
      'Kishapu',
      'Msalala',
      'Shinyanga Rural',
      'Shinyanga Urban',
      'Ushetu'
    ],
    'Simiyu': [
      'Bariadi Rural',
      'Bariadi Urban',
      'Busega',
      'Maswa',
      'Meatu',
      'Itilima'
    ],
    'Singida': [
      'Iramba',
      'Ikungi',
      'Itigi',
      'Manyoni',
      'Mkalama',
      'Singida Rural',
      'Singida Urban'
    ],
    'Songwe': ['Ileje', 'Mbozi', 'Momba', 'Songwe', 'Tunduma'],
    'Tabora': [
      'Igunga',
      'Kaliua',
      'Nzega',
      'Sikonge',
      'Tabora Rural',
      'Tabora Urban',
      'Urambo',
      'Uyui'
    ],
    'Tanga': [
      'Bumbuli',
      'Handeni Rural',
      'Handeni Urban',
      'Kilindi',
      "Korogwe Rural",
      'Korogwe Urban',
      'Lushoto',
      'Mkinga',
      'Muheza',
      'Pangani',
      'Tanga'
    ],
    'Unguja Kaskazini': ['Kaskazini Unguja A', 'Kaskazini Unguja B'],
    'Unguja Mjini Magharibi': [
      'Jiji la Zanzibar',
      'Unguja Magharibi A',
      'Unguja Magharibi B'
    ],
    'Unguja Kusini': ['Wilaya ya kati', 'Wilaya ya Kusini'],
  };
}
InputDecoration textFieldDecoration = const InputDecoration();
void displayOnScreenNotification(BuildContext context) => AlertDialog(
      //This method will use sockets to listen to the server for app live notifications
      title: const Text('System Notification'),
      actions: [
        IconButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.cancel_rounded))
      ],
    );

class TokenStorage {
  Future<void> saveToken(String key, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, token);
  }

  Future<String?> getToken(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> deleteToken(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class TokenProvider extends ChangeNotifier {
  String? _jwtToken;

  String? get jwtToken => _jwtToken;

  void updateToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }
}

class ApiService {
  Future<Map<String, dynamic>> fetchProfileInfo(String token) async {
    Response response;
    Response response2;
    Map<String, dynamic> userData = {'userName': 'UserName'};
    Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    response = await Dio().get('http://192.168.43.108:9000');
    if (response.statusCode == 200) {
      response2 = await Dio().post(
          'http://192.168.43.108:9000/registerUser/profile',
          options: Options(headers: headers));
      userData = response2.data;
    }
    debugPrint(userData["Password"]);
    return userData;
  }
}

class UserProfile {
  static const String usernameKey = 'username';
  static const String passwordKey = 'Email';

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, profile['Username']);
    await prefs.setString(passwordKey, profile['Password']);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString(usernameKey);
    String? password = prefs.getString(passwordKey);
    return {'username': username, 'password': password};
  }
}

class UserProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _userProfile;

  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> loadUserProfile() async {
    final userProfile = await UserProfile().getUserProfile();
    _userProfile = userProfile;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    _userProfile = profile;
    await UserProfile().saveUserProfile(profile);
    notifyListeners();
  }

  Future<void> clearUserProfile() async {
    _userProfile = null;
    await UserProfile().saveUserProfile({'Username': ''});
    notifyListeners();
  }
}