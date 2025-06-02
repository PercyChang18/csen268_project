import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  List<Workout> _dailyWorkouts = [];
  bool _isLoadingWorkouts = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _showWorkoutsForDate(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Dates'), centerTitle: true),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1), // set to be this year
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            headerStyle: HeaderStyle(
              // disable the changing format button
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(fontSize: 21),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white),
              weekendStyle: TextStyle(color: Color(0xFF6A6A6A)),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
              _showWorkoutsForDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          // Display workouts for the selected date here
          Expanded(
            child:
                _isLoadingWorkouts
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedDay != null
                    ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title text
                          Text(
                            'Completed Workouts on ${_selectedDay!.toLocal().toString().split(' ')[0]}:',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          //  handle the "no workout" case
                          _dailyWorkouts.isEmpty
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 32.0),
                                  child: Text(
                                    'No completed workouts recorded.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                              // display workouts in a ListView
                              : Expanded(
                                child: ListView.builder(
                                  itemCount: _dailyWorkouts.length,
                                  itemBuilder: (context, index) {
                                    final workout = _dailyWorkouts[index];
                                    // maybe change to our workout card latter
                                    return Card(
                                      elevation: 2,
                                      color: const Color(0xFF2C2C2E),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          workout.title,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        // also has a check mark
                                        trailing: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        ],
                      ),
                    )
                    : const Center(
                      child: Text(
                        'Select a date to see workouts.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWorkoutsForDate(DateTime date) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _dailyWorkouts = [];
        _isLoadingWorkouts = false;
      });
      print("User not logged in. Cannot fetch workouts for log page.");
      return;
    }

    setState(() {
      _isLoadingWorkouts = true; // Start loading
      _dailyWorkouts = []; // Clear previous workouts
    });

    try {
      final String dateDocId = date.toIso8601String().substring(0, 10);

      final DocumentSnapshot<Map<String, dynamic>> dailyWorkoutsDoc =
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('dailyWorkouts')
              .doc(dateDocId)
              .get();
      List<String> assignedWorkoutIds = [];
      List<String> completedWorkoutIds = [];

      if (dailyWorkoutsDoc.exists && dailyWorkoutsDoc.data() != null) {
        final data = dailyWorkoutsDoc.data()!;
        assignedWorkoutIds = List<String>.from(
          data['assignedWorkoutIds'] ?? [],
        );
        completedWorkoutIds = List<String>.from(
          data['completedWorkoutIds'] ?? [],
        );
      }

      if (assignedWorkoutIds.isEmpty) {
        // No workouts assigned for this day
        setState(() {
          _dailyWorkouts = [];
          _isLoadingWorkouts = false;
        });
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> assignedWorkoutsSnapshot =
          await _firestore
              .collection('workouts')
              .where(FieldPath.documentId, whereIn: assignedWorkoutIds)
              .get();

      List<Workout> fetchedWorkouts =
          assignedWorkoutsSnapshot.docs
              .map((doc) {
                final workout = Workout.fromFirestore(doc.id, doc.data());

                final bool isCompleted = completedWorkoutIds.contains(
                  workout.id,
                );
                return workout.copyWith(isCompleted: isCompleted);
              })
              .where((workout) => workout.isCompleted)
              .toList();

      setState(() {
        _dailyWorkouts = fetchedWorkouts;
        _isLoadingWorkouts = false; // Stop loading
      });
    } catch (e) {
      print(e);
    }
  }
}
