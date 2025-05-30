import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/user_profile.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final UserProfile _userProfile = UserProfile();
  final List<String> genders = ['Male', 'Female'];
  final List<String> allPurposes = [
    'Improve Physique',
    'Boost Energy',
    'Build Strength',
    'Maintain Healthy Life',
    'Improve Mood',
  ];

  final List<String> availableEquiqments = [
    'None (Bodyweight)',
    'Dumbells',
    'Resistance Bands',
  ];

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Color(0xFF3B3B3B)),
      filled: true,
      fillColor: Color(0xFFDEE3E5), // Background color of the input field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // No border line
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFFF9100), width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFFF9100), width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFFF9100), width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Information'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 40,
                color: Colors.amber,
                child: Text('User Card'),
              ),
              SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(height: 12),
                    // Gender
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: DropdownButtonFormField(
                        value: _userProfile.gender,
                        decoration: _inputDecoration('Gender'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _userProfile.gender = value;
                          });
                        },
                        onSaved: (newValue) {
                          _userProfile.gender = newValue;
                        },
                        items:
                            genders.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: TextFormField(
                        cursorColor: Color(0xFFFF9100),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d*'),
                          ),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Weight (kg)',
                        ), // Now using hintText
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userProfile.weight = double.tryParse(value ?? '');
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d*'),
                          ),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Height (cm)',
                        ), // Now using hintText
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userProfile.height = double.tryParse(value ?? '');
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Age',
                        ), // Now using hintText
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userProfile.age = int.tryParse(value ?? '');
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Purpose', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          allPurposes.map((purpose) {
                            bool isSelected = _userProfile.purposes.contains(
                              purpose,
                            );
                            return ChoiceChip(
                              // showCheckmark: false,
                              label: Text(purpose),
                              selected: isSelected,
                              selectedColor: Color(0xFFFF9100),
                              backgroundColor: Color(0xFF3B3B3B),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Color(0xFF3B3B3B)
                                        : Color(0xFFD5DBDC),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Color(0xFFFF9100)
                                          : Color(0xFFD5DBDC),
                                  width: 1.0,
                                ),
                              ),
                              onSelected: (value) {
                                if (value) {
                                  if (!_userProfile.purposes.contains(
                                    purpose,
                                  )) {
                                    _userProfile.purposes.add(purpose);
                                  }
                                } else {
                                  _userProfile.purposes.remove(purpose);
                                }
                                setState(() {});
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Available Equipments',
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          availableEquiqments.map((equipment) {
                            bool isSelected = _userProfile.availableEquiqments
                                .contains(equipment);
                            return ChoiceChip(
                              // showCheckmark: false,
                              label: Text(equipment),
                              selected: isSelected,
                              selectedColor: Color(0xFFFF9100),
                              backgroundColor: Color(0xFF3B3B3B),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Color(0xFF3B3B3B)
                                        : Color(0xFFD5DBDC),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Color(0xFFFF9100)
                                          : Color(0xFFD5DBDC),
                                  width: 1.0,
                                ),
                              ),
                              onSelected: (value) {
                                if (value) {
                                  if (!_userProfile.availableEquiqments
                                      .contains(equipment)) {
                                    _userProfile.availableEquiqments.add(
                                      equipment,
                                    );
                                  }
                                } else {
                                  _userProfile.availableEquiqments.remove(
                                    equipment,
                                  );
                                }
                                setState(() {});
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.goNamed(RouteName.home),
                          child: Text('Update'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD5DBDC),
                          ),
                          onPressed: () {
                            context.read<AuthenticationBloc>().add(
                              AuthenticationSignOutEvent(),
                            );
                          },
                          // todo: might need updates
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
