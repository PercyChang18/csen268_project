import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EndWorkoutPage extends StatefulWidget {
  const EndWorkoutPage({super.key, required this.workout});
  final Workout workout;

  @override
  State<EndWorkoutPage> createState() => _EndWorkoutPageState();
}

class _EndWorkoutPageState extends State<EndWorkoutPage> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding.instance.addPostFrameCallback to ensure the context
    // is fully available and the widget tree is built before accessing BlocProvider.
    // This is a good practice for actions that should happen immediately after the widget
    // is inserted into the tree and has a valid BuildContext.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the WorkoutCubit and call its completeWorkout method.
      // This sends the updated workout data to the Cubit, which will then:
      // 1. Update your backend (e.g., Firestore).
      // 2. Update its internal list of workouts.
      // 3. Emit a new WorkoutsLoaded state.
      BlocProvider.of<WorkoutCubit>(context).completeWorkout(widget.workout);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'Great Job! You Finish Today’s ${widget.workout.title} Exercise!',
              style: const TextStyle(fontSize: 32, color: Color(0xFFFF9100)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.workout.duration}',
                  style: const TextStyle(fontSize: 28),
                ),
                SizedBox(width: 12),
                Text(
                  'Minutes',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFFFF9100),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.workout.calories}',
                  style: const TextStyle(fontSize: 28),
                ),
                SizedBox(width: 12),
                Text(
                  'Cal',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFFFF9100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // print(context);
                // BlocProvider.of<WorkoutCubit>(context).completeWorkout(workout);
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   print("END");
                //   // Use addPostFrameCallback to ensure context is fully available,
                //   // though for BlocProvider.of it's usually fine directly in initState.
                //   BlocProvider.of<WorkoutCubit>(
                //     context,
                //   ).completeWorkout(workout);
                // });
                // BlocProvider.of<WorkoutCubit>(
                //   context,
                // ).completeWorkout(widget.workout);
                context.goNamed(RouteName.home);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
