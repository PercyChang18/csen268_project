import 'dart:async';

import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/pages/end_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StartWorkoutPage extends StatefulWidget {
  const StartWorkoutPage({super.key, required this.workout});
  final Workout workout;

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {
  Timer? timer;
  int maxSeconds = 2;
  int currentSeconds = 2;
  bool isPaused = true;
  String minutes = "";
  String seconds = "";

  @override
  // ignore: must_call_super
  void initState() {
    minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    seconds = (currentSeconds % 60).toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        centerTitle: true,
        automaticallyImplyLeading: isPaused,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Start",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 145, 0),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Image.asset(
                  widget.workout.startImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Handle errors, for example, show a placeholder
                    return const Center(child: Text('Error'));
                  },
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                "End",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 145, 0),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Image.asset(
                  widget.workout.startImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Handle errors, for example, show a placeholder
                    return const Center(child: Text('Error'));
                  },
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 145, 0),
                ),
              ),
              Text(
                widget.workout.description,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              SizedBox(height: 30.0),
              // Timer
              Column(
                children: [
                  Text(
                    '$minutes:$seconds',
                    style: TextStyle(fontSize: 30, color: Color(0xFFFF9100)),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator(
                              value: currentSeconds / maxSeconds,
                              strokeWidth: 5,
                              color: Color(0xFFFF9100),
                            ),
                          ),
                        ),

                        Center(
                          child: IconButton(
                            iconSize: 70,
                            style: IconButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Color(0xFFFF9100),
                              foregroundColor: Color(0xFF3B3B3B),
                            ),
                            onPressed: () {
                              if (isPaused) {
                                startTimer();
                              } else {
                                stopTimer();
                              }
                            },
                            icon:
                                isPaused
                                    ? Icon(Icons.play_arrow)
                                    : Icon(Icons.pause),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    timer?.cancel();
    isPaused = !isPaused;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentSeconds > 0) {
        currentSeconds--;
        minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
        seconds = (currentSeconds % 60).toString().padLeft(2, '0');
        setState(() {});
      } else {
        timer.cancel();
        isPaused = true;
        final updatedWorkout = widget.workout.copyWith(isCompleted: true);
        setState(() {});
        _completeWorkout(updatedWorkout);
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    isPaused = true;
    setState(() {});
  }

  void _completeWorkout(Workout workout) {
    // BlocProvider.of<WorkoutCubit>(context).completeWorkout(workout);
    context.goNamed(RouteName.endWorkout, extra: workout);
  }
}
