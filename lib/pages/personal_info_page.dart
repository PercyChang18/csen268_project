import 'dart:isolate';

import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/user_profile.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  UserProfile _userProfile = UserProfile();
  User? _currentUser;
  late Future<UserProfile> _userProfileFuture;

  final List<String> genders = ['Male', 'Female', 'Non-Binary'];
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

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _userProfileFuture = _loadUserProfile(_currentUser!.uid);
    }
  }

  Future<UserProfile> _loadUserProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('userProfiles')
              .doc('uid')
              .get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFireStore(doc, null);
      } else {
        _userProfile = UserProfile();
      }
      return _userProfile;
    } on FirebaseException catch (e) {
      print("error on getting data from firestore");
      return UserProfile();
    }
  }

  // Text editing controllers for the form fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Update controllers with loaded data
            _weightController.text = _userProfile.weight?.toString() ?? '';
            _heightController.text = _userProfile.height?.toString() ?? '';
            _ageController.text = _userProfile.age?.toString() ?? '';

            return Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 40,
                      // color: Colors.amber,
                      child: Text(
                        _currentUser != null
                            ? 'Welcome, ${_currentUser!.displayName ?? _currentUser!.email}'
                            : 'User Card',
                      ),
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
                              dropdownColor: Color(0xFF3B3B3B),
                              value: _userProfile.gender,
                              decoration: InputDecoration(labelText: 'Gender'),
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
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                              ),
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
                                _userProfile.weight = double.tryParse(
                                  value ?? '',
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 280,
                            height: 60,
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d*'),
                                ),
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                              ),
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
                                _userProfile.height = double.tryParse(
                                  value ?? '',
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 280,
                            height: 60,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Age'),
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
                                  bool isSelected = _userProfile.purposes
                                      .contains(purpose);
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
                                      setState(() {
                                        if (value) {
                                          if (!_userProfile.purposes.contains(
                                            purpose,
                                          )) {
                                            _userProfile.purposes.add(purpose);
                                          }
                                        } else {
                                          _userProfile.purposes.remove(purpose);
                                        }
                                      });
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
                                  bool isSelected = _userProfile
                                      .availableEquipments
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
                                      setState(() {
                                        if (value) {
                                          if (!_userProfile.availableEquipments
                                              .contains(equipment)) {
                                            _userProfile.availableEquipments
                                                .add(equipment);
                                          }
                                        } else {
                                          _userProfile.availableEquipments
                                              .remove(equipment);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    // Save the updated profile to Firestore
                                    if (_currentUser != null) {
                                      FirebaseFirestore.instance
                                          .collection('userProfiles')
                                          .doc(_currentUser!.uid)
                                          .set(_userProfile.toFireStore())
                                          .then((_) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Profile updated successfully!',
                                                ),
                                              ),
                                            );
                                          })
                                          .catchError((error) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to update profile: $error',
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                    context.goNamed(RouteName.home);
                                  }
                                },
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
            );
          } else {
            return const Center(child: Text('No user profile found.'));
          }
        },
      ),
    );
  }
}
