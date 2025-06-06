import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'workout_state.dart';

enum WorkoutPlan { high, medium, low }

class WorkoutCubit extends Cubit<WorkoutState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Workout> workouts = [];
  late StreamSubscription<User?> _authStateSubscription;
  int totalWorkoutTime = 0;
  double totalWorkoutCal = 0;

  final Set<int> _lowWorkoutDays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.thursday,
  };
  final Set<int> _mediumWorkoutDays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
    DateTime.saturday,
  };
  final Set<int> _highWorkoutDays = {
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.saturday,
  };

  // TODO: Complete the plans.
  final Map<int, List<String>> _lowWorkoutPlan = {
    DateTime.monday: ["Chest", "Back"],
    DateTime.wednesday: ["Abs", "Leg"],
    DateTime.thursday: ["Cardio", "Abs"],
  };

  final Map<int, List<String>> _mediumWorkoutPlan = {
    DateTime.monday: ["Chest", "Back"],
    DateTime.wednesday: ["Abs", "Leg"],
    DateTime.friday: ["Cardio", "Back"],
    DateTime.saturday: ["Abs", "Shoulder", "Leg"],
  };

  final Map<int, List<String>> _highWorkoutPlan = {
    DateTime.tuesday: ["Chest", "Leg", "Abs", "Cardio"],
    DateTime.wednesday: ["Abs", "Shoulder", "Leg"],
    DateTime.thursday: ["Chest", "Back", "Cardio", "Leg"],
    DateTime.saturday: ["Shoulder", "Leg", "Cardio"],
  };

  WorkoutCubit() : super(WorkoutInitial()) {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print(
          "Auth state changed: User is logged in (${user.uid}). Initializing workouts.",
        );
        init();
      } else {
        print("Auth state changed: User is logged out.");
        emit(WorkoutInitial());
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel(); // Cancel the subscription
    return super.close();
  }

  void init({bool reassign = false}) async {
    if (reassign) {
      print("Reassign in init!");
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    // should not happen, but if the user is not logged in
    if (currentUser == null) {
      print("User is not logged in!");
      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      List<String> userAvailableEquipments = [];
      List<String> userPurposes = [];
      if (userDoc.exists && userDoc.data() != null) {
        userAvailableEquipments = List<String>.from(
          userDoc.data()!['availableEquipment'] ?? [],
        );
        userPurposes = List<String>.from(userDoc.data()!['purpose'] ?? []);
      }
      print("User's available equipment: $userAvailableEquipments");
      print("User's purpose: $userPurposes");

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final String todayDocId = today.toIso8601String().substring(0, 10);

      bool needsAssignment = true;
      WorkoutPlan plan = WorkoutPlan.high;

      // Workout assignments
      if (userPurposes.contains('Improve Physique') &&
          userPurposes.contains('Build Strength')) {
        plan = WorkoutPlan.high;
        if (!_highWorkoutDays.contains(today.weekday)) {
          needsAssignment = false;
          print("No workout for today!");
          emit(WorkoutsLoaded(workouts: [], totalTime: 0, totalCal: 0));
          return;
        }
      } else if (userPurposes.contains('Improve Physique') ||
          userPurposes.contains('Build Strength')) {
        plan = WorkoutPlan.medium;
        if (!_mediumWorkoutDays.contains(today.weekday)) {
          needsAssignment = false;
          print("No workout for today!");
          emit(WorkoutsLoaded(workouts: [], totalTime: 0, totalCal: 0));
          return;
        }
      } else {
        plan = WorkoutPlan.low;
        if (!_lowWorkoutDays.contains(today.weekday)) {
          needsAssignment = false;
          print("No workout for today!");
          emit(WorkoutsLoaded(workouts: [], totalTime: 0, totalCal: 0));
          return;
        }
      }

      final DocumentReference<Map<String, dynamic>> dailyWorkoutsDocRef =
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('dailyWorkouts')
              .doc(todayDocId);

      DocumentSnapshot<Map<String, dynamic>> dailyWorkoutsDoc =
          await dailyWorkoutsDocRef.get();

      List<String> assignedWorkoutIds = [];
      List<String> completedWorkoutIdsForToday =
          []; // To store completed IDs from Firestore

      totalWorkoutTime = 0;
      totalWorkoutCal = 0;
      if (dailyWorkoutsDoc.exists && dailyWorkoutsDoc.data() != null) {
        final data = dailyWorkoutsDoc.data()!;
        assignedWorkoutIds = List<String>.from(
          data['assignedWorkoutIds'] ?? [],
        );
        completedWorkoutIdsForToday = List<String>.from(
          data['completedWorkoutIds'] ?? [],
        ); // Load completed IDs
        if (!reassign && assignedWorkoutIds.isNotEmpty) {
          needsAssignment = false;
        }
        totalWorkoutTime = data['totalTime'] ?? 0;
        totalWorkoutCal = (data['totalCal'] as num?)?.toDouble() ?? 0;
      }
      List<Workout> selectedWorkouts = [];
      // Get the categories of completed workouts. Don't reassign these category.
      List<Future<String>> completedWorkoutRef =
          completedWorkoutIdsForToday
              .map((id) => _getCompletedWorkoutCategory(id))
              .toList();
      List<String> completedCategories = await Future.wait(completedWorkoutRef);
      print(completedCategories);

      if (needsAssignment) {
        print('Assigning new workouts for today...');
        final List<Workout> allWorkouts = await _getAllWorkouts();
        if (allWorkouts.isEmpty) {
          emit(WorkoutsError(message: 'No workouts available to assign.'));
          return;
        }

        final List<Workout> availableWorkouts =
            allWorkouts.where((workout) {
              // print('Workout: ${workout.title}, ${workout.equipments}');
              return workout.equipments!.any(
                (equipment) => userAvailableEquipments.contains(equipment),
              );
            }).toList();

        switch (plan) {
          case WorkoutPlan.high:
            for (String category in _highWorkoutPlan[today.weekday]!) {
              if (!completedCategories.contains(category)) {
                List<Workout> workoutsInCategory =
                    availableWorkouts
                        .where((workout) => workout.category == category)
                        .toList();
                if (workoutsInCategory.isNotEmpty) {
                  selectedWorkouts.add(
                    workoutsInCategory[Random().nextInt(
                      workoutsInCategory.length,
                    )],
                  );
                }
              }
            }
            assignedWorkoutIds = selectedWorkouts.map((w) => w.id).toList();

            print("Assign workouts: $assignedWorkoutIds");

          case WorkoutPlan.medium:
            for (String category in _mediumWorkoutPlan[today.weekday]!) {
              if (!completedCategories.contains(category)) {
                List<Workout> workoutsInCategory =
                    availableWorkouts
                        .where((workout) => workout.category == category)
                        .toList();
                if (workoutsInCategory.isNotEmpty) {
                  selectedWorkouts.add(
                    workoutsInCategory[Random().nextInt(
                      workoutsInCategory.length,
                    )],
                  );
                }
              }
            }
            assignedWorkoutIds = selectedWorkouts.map((w) => w.id).toList();
            print(assignedWorkoutIds);

          case WorkoutPlan.low:
            for (String category in _lowWorkoutPlan[today.weekday]!) {
              if (!completedCategories.contains(category)) {
                List<Workout> workoutsInCategory =
                    availableWorkouts
                        .where((workout) => workout.category == category)
                        .toList();
                if (workoutsInCategory.isNotEmpty) {
                  selectedWorkouts.add(
                    workoutsInCategory[Random().nextInt(
                      workoutsInCategory.length,
                    )],
                  );
                }
              }
            }
            assignedWorkoutIds = selectedWorkouts.map((w) => w.id).toList();
            print(assignedWorkoutIds);
        }

        assignedWorkoutIds.addAll(completedWorkoutIdsForToday);

        await dailyWorkoutsDocRef.set({
          'date': Timestamp.fromDate(today),
          'assignedWorkoutIds': assignedWorkoutIds,
          'completedWorkoutIds': completedWorkoutIdsForToday,
          'totalTime': totalWorkoutTime,
          'totalCal': totalWorkoutCal,
        });
        print(
          'Workouts assigned and updated in user dailyWorkouts subcollection.',
        );
      } else {
        print('Workouts already assigned for today. Fetching existing ones.');
      }

      print("Completed Workouts: $completedWorkoutIdsForToday");

      if (assignedWorkoutIds.isEmpty) {
        workouts = [];
        emit(
          WorkoutsLoaded(
            workouts: workouts,
            totalTime: totalWorkoutTime,
            totalCal: totalWorkoutCal,
          ),
        );
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> assignedWorkoutsSnapshot =
          await _firestore
              .collection('workouts')
              .where(FieldPath.documentId, whereIn: assignedWorkoutIds)
              .get();

      workouts =
          assignedWorkoutsSnapshot.docs.map((doc) {
            final workout = Workout.fromFirestore(doc.id, doc.data());
            // Set isCompleted based on the loaded completedWorkoutIdsForToday
            final bool isCompleted = completedWorkoutIdsForToday.contains(
              workout.id,
            );
            return workout.copyWith(isCompleted: isCompleted);
          }).toList();
      emit(
        WorkoutsLoaded(
          workouts: List.from(workouts),
          totalTime: totalWorkoutTime,
          totalCal: totalWorkoutCal,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void test() {
    emit(TestView());
  }

  // Helper to fetch all available workouts
  Future<List<Workout>> _getAllWorkouts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('workouts').get();
      return snapshot.docs
          .map((doc) => Workout.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all workouts: $e');
      return [];
    }
  }

  Future<String> _getCompletedWorkoutCategory(String id) async {
    try {
      final DocumentReference<Map<String, dynamic>> workoutsDocRef = _firestore
          .collection('workouts')
          .doc(id);
      DocumentSnapshot<Map<String, dynamic>> workoutsDoc =
          await workoutsDocRef.get();
      return workoutsDoc.data()?['category'];
    } catch (e) {
      print('Error getting all workouts: $e');
      return "";
    }
  }

  // Called when a workout is completed
  Future<void> completeWorkout(
    Workout workout,
    int workoutTime,
    double calories,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("User is not logged in.");
      return;
    }
    if (workout.id.isEmpty) {
      print("Workout ID is empty.");
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final String todayDocId = today.toIso8601String().substring(0, 10);

    // Reference to today's daily workout document within the user's subcollection
    final DocumentReference<Map<String, dynamic>> dailyWorkoutsDocRef =
        _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('dailyWorkouts')
            .doc(todayDocId);

    try {
      // Find the workout in the local list
      final index = workouts.indexWhere((w) => w.id == workout.id);
      if (index == -1) {
        print("Workout not found in local list. Cannot toggle completion.");
        return;
      }
      DocumentSnapshot<Map<String, dynamic>> dailyWorkoutsDoc =
          await dailyWorkoutsDocRef.get();

      totalWorkoutTime =
          (dailyWorkoutsDoc.data()!['totalTime'] as num?)?.toInt() ?? 0;
      // print("Time: $totalWorkoutTime");
      totalWorkoutCal =
          (dailyWorkoutsDoc.data()!['totalCal'] as num?)?.toDouble() ?? 0;

      totalWorkoutTime += workoutTime;
      totalWorkoutCal += calories;

      await dailyWorkoutsDocRef.update({
        'completedWorkoutIds': FieldValue.arrayUnion([workout.id]),
      });

      await dailyWorkoutsDocRef.set({
        'totalTime': totalWorkoutTime,
        'totalCal': totalWorkoutCal,
      }, SetOptions(merge: true));
      // Update local state
      workouts[index] = workouts[index].copyWith(
        // duration: workoutTime,
        // calories: calories,
        isCompleted: true,
      );
      print('Workout ${workout.title} marked as COMPLETED for today.');

      emit(
        WorkoutsLoaded(
          workouts: List.from(workouts),
          totalTime: totalWorkoutTime,
          totalCal: totalWorkoutCal,
        ),
      );
    } catch (e) {
      print('Error toggling workout completion in Firebase: $e');
      emit(WorkoutsError(message: 'Failed to update workout status: $e'));
    }
  }

  // Called when user changes available equipments
  void reassign() {
    print("Reassign!");
    init(reassign: true);
  }
}
