import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/test_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Workout> workouts = [];
  late StreamSubscription<User?> _authStateSubscription;

  final Set<int> _lowWorkoutDays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };
  final Set<int> _highWorkoutDays = {
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
    DateTime.saturday,
  };

  // TODO: Complete the plans.
  final Map<int, List<String>> _lowWorkoutPlan = {
    DateTime.monday: ["Chest", "Back"],
    DateTime.wednesday: ["Abs", "Leg"],
  };
  final Map<int, List<String>> _highWorkoutPlan = {
    DateTime.monday: ["Chest", "Back", "Abs"],
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
    print('Use: $currentUser');
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
      bool highWorkout = true;

      // Workout assignment:
      // If contain Improve Physique or Build Strength: assign 4 days a week.
      // Else: 3 days a week.
      if (userPurposes.contains('Improve Physique') ||
          userPurposes.contains('Build Strength')) {
        if (!_highWorkoutDays.contains(today.weekday)) {
          needsAssignment = false;
          print("No workout for today!");
          emit(WorkoutsLoaded(workouts: []));
          return;
        }
      } else {
        highWorkout = false;
        if (!_lowWorkoutDays.contains(today.weekday)) {
          needsAssignment = false;
          print("No workout for today!");
          emit(WorkoutsLoaded(workouts: []));
          return;
        }
      }

      // TODO: assign based on category

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
      }
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

        List<Workout> selectedWorkouts = [];

        if (highWorkout) {
          for (String category in _highWorkoutPlan[today.weekday]!) {
            List<Workout> workoutsInCategory =
                availableWorkouts
                    .where((workout) => workout.category == category)
                    .toList();
            print("cate workout: $workoutsInCategory");
            if (workoutsInCategory.isNotEmpty) {
              selectedWorkouts.add(
                workoutsInCategory[Random().nextInt(workoutsInCategory.length)],
              );
            }
          }
          assignedWorkoutIds = selectedWorkouts.map((w) => w.id).toList();
          print(assignedWorkoutIds);
        } else {
          for (String category in _lowWorkoutPlan[today.weekday]!) {
            List<Workout> workoutsInCategory =
                availableWorkouts
                    .where((workout) => workout.category == category)
                    .toList();
            print("cate workout: $workoutsInCategory");
            if (workoutsInCategory.isNotEmpty) {
              selectedWorkouts.add(
                workoutsInCategory[Random().nextInt(workoutsInCategory.length)],
              );
            }
          }
          assignedWorkoutIds = selectedWorkouts.map((w) => w.id).toList();
          print(assignedWorkoutIds);
        }

        await dailyWorkoutsDocRef.set({
          'date': Timestamp.fromDate(today),
          'assignedWorkoutIds': assignedWorkoutIds,
          'completedWorkoutIds': completedWorkoutIdsForToday,
          // [], // Always initialize empty for a new day's assignment
        });
        print(
          'Workouts assigned and updated in user dailyWorkouts subcollection.',
        );
        // No workouts are completed yet on a new assignment
        // completedWorkoutIdsForToday = [];
      } else {
        print('Workouts already assigned for today. Fetching existing ones.');
      }

      print("Completed Workouts: $completedWorkoutIdsForToday");

      if (assignedWorkoutIds.isEmpty) {
        workouts = [];
        emit(WorkoutsLoaded(workouts: workouts));
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

      print('workouts: $workouts');
      emit(WorkoutsLoaded(workouts: List.from(workouts)));
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

  // Called when a workout is completed
  Future<void> completeWorkout(Workout workout) async {
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

      await dailyWorkoutsDocRef.update({
        'completedWorkoutIds': FieldValue.arrayUnion([workout.id]),
      });
      // Update local state
      workouts[index] = workouts[index].copyWith(isCompleted: true);
      print('Workout ${workout.title} marked as COMPLETED for today.');

      emit(WorkoutsLoaded(workouts: List.from(workouts)));
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
