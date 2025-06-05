import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/user_profile.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _selectedTime;

  final List<String> genders = ['Male', 'Female', 'Non-binary'];
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
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;

  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(); // ADD THIS
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();

    if (_currentUser != null) {
      _userEmail = _currentUser!.email;
      _loadAndSetUserProfile();
    } else {
      // should not have not signed in state and able to see this page
    }
  }

  Future<void> _loadAndSetUserProfile() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userProfile = UserProfile.fromFireStore(userDoc, null);
          _nameController.text = _userProfile.name ?? '';
          _weightController.text = _userProfile.weight?.toString() ?? '';
          _heightController.text = _userProfile.height?.toString() ?? '';
          _ageController.text = _userProfile.age?.toString() ?? '';
          // notification settings
          if (_userProfile.reminderTime != null) {
            final parts = _userProfile.reminderTime!.split(':');
            _selectedTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      }
    } on FirebaseException catch (e) {
      print("Error on getting data from Firestore: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.message}')),
      );
    }
  }

  // pick notification time
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // centerTitle: true,
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
                height: 80,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // This Text widget can now listen to the controller for real-time updates if you want
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nameController,
                        builder: (context, value, child) {
                          return Text(
                            value.text.isNotEmpty
                                ? "Welcome! " + value.text
                                : 'User Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        _userEmail ?? 'No Email',
                        style: const TextStyle(fontSize: 16),
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
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    // Name
                    SizedBox(
                      width: 280,
                      height: 60,
                      child: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-zA-Z\s]'),
                          ),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userProfile.name = value;
                        },
                      ),
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
                    Text(
                      'Notification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime != null
                                ? 'Remind me at: ${_selectedTime!.format(context)}'
                                : 'No reminder set',
                            style: const TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                            onPressed: _pickTime,
                            child: Text(
                              _selectedTime != null ? 'Change' : 'Set Time',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Purpose',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
                    Text(
                      'Available Equipments',
                      style: Theme.of(context).textTheme.titleLarge,
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _userProfile.weight = double.tryParse(
                                _weightController.text,
                              );
                              _userProfile.height = double.tryParse(
                                _heightController.text,
                              );
                              _userProfile.age = int.tryParse(
                                _ageController.text,
                              );
                              // if selected notification time is not null
                              if (_selectedTime != null) {
                                _userProfile.reminderTime =
                                    '${_selectedTime!.hour}:${_selectedTime!.minute}';
                                await _notificationService
                                    .scheduleDailyWorkoutReminder(
                                      _selectedTime!,
                                    );
                              } else {
                                _userProfile.reminderTime = null;
                                await _notificationService
                                    .cancelAllNotifications();
                              }
                              if (_currentUser != null) {
                                // SAVE to 'users'!
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_currentUser!.uid)
                                      .set(
                                        _userProfile.toFireStore(),
                                        SetOptions(merge: true),
                                      );
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profile updated successfully!',
                                      ),
                                    ),
                                  );
                                  context.read<WorkoutCubit>().reassign();
                                  context.goNamed(RouteName.home);
                                } catch (error) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update profile: $error',
                                      ),
                                    ),
                                  );
                                }
                              }
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
