import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medconnect/logic.dart';
import 'package:provider/provider.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> with Logic {
  Future uploadPersonalData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Response response;
        response = await Dio().get('http://192.168.43.108:9000');
        if (response.statusCode == 200) {
          Response response2;
          response2 = await Dio()
              .post('http://192.168.43.108:9000/registerUser', data: {
            'FirstName': firstName,
            'MiddleName': middleName,
            'SurName': surName,
            'BirthDate': birthDate,
            'Gender': userGender
          });
          //debugPrint(response2.data);
          uniqueId = response2.data;
          debugPrint(uniqueId);
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/Recruitment',
                arguments: uniqueId);
          }
        }
      } on DioException catch (error) {
        if (context.mounted) {
          return AlertDialog(
            content: Text(error.message.toString()),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    uploadPersonalData(context);
                  },
                  child: const Text('Retry')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
            ],
          );
        }
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? firstName;
  String? middleName;
  String? surName;
  String? userGender;
  String? birthDate;

  final TextEditingController _date = TextEditingController();
  List<DropdownMenuItem<String>> gender = [
    const DropdownMenuItem(value: 'Male', child: Text('Male')),
    const DropdownMenuItem(value: 'Female', child: Text('Female'))
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                //First Name
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert your First Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    firstName = value!;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Your First Name', labelText: 'First Name'),
                ),
                //Middle Name
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Insert your Middle Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      middleName = value!;
                    },
                    decoration: const InputDecoration(
                        hintText: 'Your Middle Name',
                        labelText: 'Middle Name')),
                //Sur Name
                TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Insert your Sur Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      surName = value!;
                    },
                    decoration: const InputDecoration(
                        hintText: 'Your Sur Name', labelText: 'Sur Name')),
                DropdownButtonFormField(
                  items: gender,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Specify your Gender';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    userGender = value!;
                  },
                  onChanged: (String? usergender) {
                    //if it doesn't work use onSaved
                    usergender = userGender;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Your Gender', labelText: 'Gender'),
                ),
                //Date of Birth
                TextFormField(
                  controller: _date,
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert Your date of Birth';
                    }
                    return null;
                  },
                  onTap: () async {
                    //if it doesn't work try using onSaved
                    DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.utc(1960),
                        lastDate: DateTime.now());

                    if (selectedDate != null) {
                      //birthDate = selectedDate;
                      _date.text = selectedDate.toString();
                    }
                  },
                  onSaved: (value) {
                    birthDate = value!;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Your Date of Birth',
                      labelText: 'Date of Birth'),
                ),
                ElevatedButton(
                  onPressed: () {
                    uploadPersonalData(context);
                  },
                  child: const Text('Proceed'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Login');
                    },
                    child: const Text('Have an Account? Login')),
              ]),
            ),
          ),
        )),
      ),
    );
  }
}

class RecruitmentInfo extends StatefulWidget {
  final String uniqueId;
  const RecruitmentInfo({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<RecruitmentInfo> createState() => _RecruitmentInfoState();
}

class _RecruitmentInfoState extends State<RecruitmentInfo> with Logic {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _districtDropdownKey = GlobalKey();

  String? institution;
  String? license;
  String? city;
  String? recruitmentDistrict;
  String? useroccupation;
  String? selectedCity;
  List<String> availableDistricts = [];

  Future uploadRecruitmentInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Response response;
        response = await Dio().get('http://192.168.43.108:9000');
        if (response.statusCode == 200) {
          await Dio().post(
              'http://192.168.43.108:9000/registerUser/RecruitmentInfo',
              data: {
                'City': city,
                'District': recruitmentDistrict,
                'Occupation': useroccupation,
                'Institution': institution,
                'License': license,
                'Id': widget.uniqueId
              });
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/Contact',
                arguments: widget.uniqueId);
          }
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.badResponse) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionError) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.sendTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else {
          return const AlertDialog(content: Text('Connection Error'));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Center(
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Text('Recruitment Information'),
                        DropdownButtonFormField(
                            items: region,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Specify Recruitment City';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              city = value!;
                            },
                            onChanged: (String? selectedCity) {
                              setState(() {
                                this.selectedCity = selectedCity;
                                recruitmentDistrict = null;
                                availableDistricts =
                                    districts[selectedCity] ?? [];
                                city = selectedCity;
                                _districtDropdownKey.currentState?.reset();
                              });
                            },
                            decoration: const InputDecoration(
                                labelText: 'Your recruitment City',
                                hintText: 'eg Kagera',
                                icon: Icon(Icons.location_city))),
                        DropdownButtonFormField(
                            key: _districtDropdownKey,
                            items: availableDistricts
                                .map((district) => DropdownMenuItem(
                                      value: district,
                                      child: Text(district),
                                    ))
                                .toList(),
                            onChanged: (String? selectedDistrict) {
                              setState(() {
                                recruitmentDistrict = selectedDistrict;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Spcify your recruitment district';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              recruitmentDistrict = value!;
                            },
                            decoration: const InputDecoration(
                              labelText: 'District',
                              hintText: 'eg Bukoba',
                              icon: Icon(Icons.apartment_outlined),
                            )),
                        DropdownButtonFormField(
                          items: occupation,
                          onChanged: (String? occupation) {
                            setState(() {
                              useroccupation = occupation;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Spcify your Occupation';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            useroccupation = value!;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Your Occupation',
                            hintText: 'eg Pharamacist',
                            icon: Icon(Icons.medical_services),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify your Institution';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            institution = value!;
                          },
                          decoration: const InputDecoration(
                              hintText: 'eg Bukoba Regional Referral Hospital',
                              labelText: 'Institution',
                              icon: Icon(Icons.local_hospital)),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify your license';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            license = value!;
                          },
                          decoration: const InputDecoration(
                              hintText: 'eg MD-1224349',
                              labelText: 'License Number',
                              icon: Icon(Icons.pin)),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              uploadRecruitmentInfo();
                            },
                            child: const Text('Proceed')),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/Login');
                            },
                            child: const Text('Have an Account? Login')),
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}

class ContactInfo extends StatefulWidget {
  final String uniqueId;
  const ContactInfo({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> with Logic {
  Future uploadContactInfo(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Response response;
        response = await Dio().get('http://192.168.43.108:9000');
        if (response.statusCode == 200) {
          await Dio().post(
              'http://192.168.43.108:9000/registerUser/ContactInfo',
              data: {'Email': email, 'Phone': phone, 'Id': widget.uniqueId});
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/Account',
                arguments: widget.uniqueId);
          }
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.badResponse) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionError) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.sendTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else {
          return const AlertDialog(content: Text('Connection Error'));
        }
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? email;
  String? phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      const Text('Contact Information'),
                      TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Insert your Email address';
                            } else if (!value.contains('@')) {
                              return 'Invalid Email Address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            email = value!;
                            debugPrint('Email value $value');
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'eg allenernest@yahoo.com',
                              labelText: 'Email Address',
                              icon: Icon(Icons.email_rounded))),
                      TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Insert your Phone number';
                            } else if (value.length < 13) {
                              return 'Invalid Phone number, the number should begin with +255 should have atotal of 13 characters';
                            } else if (!value.startsWith('+255')) {
                              return 'Invalid Phone number, the number should begin with +255 should have atotal of 13 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            phone = value!;
                          },
                          maxLength: 13,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              hintText: 'eg +255621233212',
                              labelText: 'Phone Number',
                              icon: Icon(Icons.phone))),
                      ElevatedButton(
                          onPressed: () {
                            uploadContactInfo(context);
                          },
                          child: const Text('Proceed')),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/Login');
                          },
                          child: const Text('Have an Account? Login')),
                    ]),
                  ),
                ))));
  }
}

class AccountInfo extends StatefulWidget {
  final String uniqueId;
  const AccountInfo({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> with Logic {
  String? username;
  String? password;
  String jwtToken = '';
  late TokenStorage tokenStorage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    tokenStorage = Provider.of<TokenStorage>(context, listen: false);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future uploadAccountinfo(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        Response response;
        response = await Dio().get('http://192.168.43.108:9000');
        if (response.statusCode == 200) {
          Response response2 = await Dio().post(
              'http://192.168.43.108:9000/registerUser/AccountInfo',
              data: {
                'UserName': username,
                'Password': password,
                'Id': widget.uniqueId
              });
          jwtToken = response2.data['token'];
          await tokenStorage.saveToken('jwtToken', jwtToken);
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/Profile');
          }
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.badResponse) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.connectionError) {
          return AlertDialog(content: Text(error.message.toString()));
        } else if (error.type == DioExceptionType.sendTimeout) {
          return AlertDialog(content: Text(error.message.toString()));
        } else {
          return const AlertDialog(content: Text('Connection Error'));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              const Text(
                'AccountInfo',
                style: TextStyle(fontSize: 20),
              ),
              TextFormField(
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please insert your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value!;
                },
                decoration: const InputDecoration(
                    hintText: 'eg @AllenErnest120',
                    labelText: 'Your User Name',
                    icon: Icon(Icons.person_2_rounded)),
              ),
              TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert your Password';
                    } else if (value.length < 8) {
                      return 'The password should have a minimum of 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum of 8 characters',
                    labelText: 'Password',
                    icon: const Icon(Icons.password_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: _togglePasswordVisibility,
                    ),
                  )),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Confirm password';
                  } else if (value != password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm your Password',
                  labelText: 'Confirm Password',
                  icon: Icon(Icons.password_rounded),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    uploadAccountinfo(context);
                  },
                  child: const Text('Proceed'))
            ]),
          )),
    ));
  }
}
