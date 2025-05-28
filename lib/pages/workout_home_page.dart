import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/widgets/workout_card.dart';
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
    final workoutMinutes = 18;
    // final recommendations = [
    //   Workout(
    //     title: "Back",
    //     startImage: "startImage",
    //     endImage: "endImage",
    //     description: "description",
    //     duration: 5,
    //     calories: 10,
    //   ),
    //   Workout(
    //     title: "Chest",
    //     startImage: "startImage",
    //     endImage: "endImage",
    //     description: "description",
    //     duration: 5,
    //     calories: 10,
    //   ),
    //   Workout(
    //     title: "Abs",
    //     startImage: "startImage",
    //     endImage: "endImage",
    //     description: "description",
    //     duration: 5,
    //     calories: 10,
    //   ),
    //   Workout(
    //     title: "Abs",
    //     startImage: "startImage",
    //     endImage: "endImage",
    //     description: "description",
    //     duration: 5,
    //     calories: 10,
    //   ),
    // ];

    return Scaffold(
      appBar: AppBar(title: Text('🏋️ Keep it up!'), centerTitle: true),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutsLoaded) {
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
                ],
              ),
            );
          } else {
            return Placeholder();
          }
        },
      ),
    );
  }
}
