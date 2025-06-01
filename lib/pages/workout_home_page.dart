// import 'package:csen268_project/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/widgets/workout_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import '../component/workout_card.dart';

class WorkoutHomePage extends StatelessWidget {
  const WorkoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final stepsToday = 7450;

    // Get the current user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('🏋️ Keep it up!'), centerTitle: true),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutsLoaded) {
            int workoutMinutes = 0;
            for (var workout in state.workouts) {
              if (workout.isCompleted) {
                workoutMinutes += workout.duration;
              }
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.directions_walk),
                          const SizedBox(height: 8),
                          Text('$stepsToday Steps'),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.timer),
                          const SizedBox(height: 8),
                          Text('$workoutMinutes min'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 29.0),
                  Text("Workout Today", style: textTheme.titleLarge),
                  SizedBox(height: 29.0),
                  Wrap(
                    spacing: 31,
                    runSpacing: 31,
                    alignment: WrapAlignment.start,
                    children:
                        state.workouts
                            .map(
                              (workout) => InkWell(
                                onTap: () {
                                  context.goNamed(
                                    RouteName.startWorkout,
                                    extra: workout,
                                  );
                                },
                                child: WorkoutCard(workout: workout),
                              ),
                            )
                            .toList(),
                  ),
                  // TODO: This is just a stream builder example. Delete if not needed.
                  // StreamBuilder<DocumentSnapshot>(
                  //   stream:
                  //       FirebaseFirestore.instance
                  //           .collection('users')
                  //           .doc(currentUser?.uid)
                  //           .snapshots(),
                  //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //     if (snapshot.hasData) {
                  //       return Text('Hello: ${snapshot.data.data()['height']}');
                  //     }
                  //     return Text('Welcome');
                  //   },
                  // ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
