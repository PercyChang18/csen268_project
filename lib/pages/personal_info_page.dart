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

  final List<String> genders = ['Male', 'Female', 'Non-Binary'];
  final List<String> allPurposes = [
    'Improve Physique',
    'Boost Energy',
    'Build Strength',
    'Maintain Healthy Life',
    'Improve Mood',
  ];

  final List<String> availableEquipments = [
    'None (Bodyweight)',
    'Dumbbells',
    'Resistance Bands',
  ];

  // Text editing controllers for the form fields
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;

  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();

    if (_currentUser != null) {
      _userName = _currentUser!.displayName;
      _userEmail = _currentUser!.email;
      _loadAndSetUserProfile();
    } else {
      // should not have not signed in state and able to see this page
    }
  }

  Future<void> _loadAndSetUserProfile() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          // NOTE: our data is stored in the collection 'users'
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userProfile = UserProfile.fromFireStore(userDoc, null);
          _weightController.text = _userProfile.weight?.toString() ?? '';
          _heightController.text = _userProfile.height?.toString() ?? '';
          _ageController.text = _userProfile.age?.toString() ?? '';
        });
      } else {}
    } on FirebaseException catch (e) {
      print("Error on getting data from Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.message}')),
      );
    }
  }

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 80, // Adjusted height to accommodate name and email
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // TODO: we need to ask user's name
                        _userName ?? 'User Card',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userEmail ?? 'No Email',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    // Gender
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF3B3B3B),
                        value: _userProfile.gender,
                        decoration: const InputDecoration(labelText: 'Gender'),
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
                    const SizedBox(height: 12),
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
                        decoration: const InputDecoration(
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
                          _userProfile.weight = double.tryParse(value ?? '');
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        decoration: const InputDecoration(
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
                          _userProfile.height = double.tryParse(value ?? '');
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        decoration: const InputDecoration(labelText: 'Age'),
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
                    const SizedBox(height: 20),
                    const Text('Purpose', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          allPurposes.map((purpose) {
                            bool isSelected = _userProfile.purposes.contains(
                              purpose,
                            );
                            return ChoiceChip(
                              label: Text(purpose),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFF9100),
                              backgroundColor: const Color(0xFF3B3B3B),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF3B3B3B)
                                        : const Color(0xFFD5DBDC),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? const Color(0xFFFF9100)
                                          : const Color(0xFFD5DBDC),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Available Equipments',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          availableEquipments.map((equipment) {
                            bool isSelected = _userProfile.availableEquipments
                                .contains(equipment);
                            return ChoiceChip(
                              label: Text(equipment),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFF9100),
                              backgroundColor: const Color(0xFF3B3B3B),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF3B3B3B)
                                        : const Color(0xFFD5DBDC),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? const Color(0xFFFF9100)
                                          : const Color(0xFFD5DBDC),
                                  width: 1.0,
                                ),
                              ),
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    if (!_userProfile.availableEquipments
                                        .contains(equipment)) {
                                      _userProfile.availableEquipments.add(
                                        equipment,
                                      );
                                    }
                                  } else {
                                    _userProfile.availableEquipments.remove(
                                      equipment,
                                    );
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              // Update user profile with current controller values
                              _userProfile.weight = double.tryParse(
                                _weightController.text,
                              );
                              _userProfile.height = double.tryParse(
                                _heightController.text,
                              );
                              _userProfile.age = int.tryParse(
                                _ageController.text,
                              );
                              if (_currentUser != null) {
                                // SAVE to 'users'!
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_currentUser!.uid)
                                    .set(
                                      _userProfile.toFireStore(),
                                      SetOptions(merge: true),
                                    ) // Use merge option
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
                          child: const Text('Update'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD5DBDC),
                          ),
                          onPressed: () {
                            context.read<AuthenticationBloc>().add(
                              AuthenticationSignOutEvent(),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
