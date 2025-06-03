import 'dart:async';

import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/pages/end_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
  int workoutSeconds = 0;
  bool isPaused = true;
  String minutes = "";
  String seconds = "";

  // For Outrunning
  bool isGpsOn = false;
  double totalDistance = 0.0;
  Position? lastPosition;
  String locationStatus = "Checking GPS...";
  StreamSubscription<Position>? positionStreamSubscription;
  bool isTracking = false;

  @override
  // ignore: must_call_super
  void initState() {
    minutes = (workoutSeconds ~/ 60).toString().padLeft(2, '0');
    seconds = (workoutSeconds % 60).toString().padLeft(2, '0');
    if (widget.workout.title == 'Outdoor Run') {
      checkGpsStatus();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        centerTitle: true,
        automaticallyImplyLeading: isPaused && currentSeconds > 0,
      ),
      body:
          widget.workout.title == "Outdoor Run"
              ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(fontSize: 18, color: Color(0xFFFF9100)),
                    ),
                    Text(
                      widget.workout.description,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      "GPS: ${isGpsOn ? "ON" : "OFF"}",
                      style: TextStyle(
                        // fontSize: 14,
                        color: isGpsOn ? Color(0xFFFF9100) : Colors.red,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text("Status: $locationStatus"),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              Text(
                                '$minutes:$seconds',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFFFF9100),
                                ),
                              ),
                              Text("Time"),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              Text(
                                totalDistance.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Color(0xFFFF9100),
                                ),
                              ),
                              Text("m"),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              Text(
                                "110",
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Color(0xFFFF9100),
                                ),
                              ),
                              Text("Cal"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: CircularProgressIndicator(
                                    value: currentSeconds / maxSeconds,
                                    strokeWidth: 4,
                                    color: Color(0xFFFF9100),
                                  ),
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  iconSize: 53,
                                  style: IconButton.styleFrom(
                                    shape: CircleBorder(),
                                    backgroundColor: Color(0xFFFF9100),
                                    foregroundColor: Color(0xFF3B3B3B),
                                  ),
                                  onPressed: () {
                                    if (!isTracking) {
                                      startTracking();
                                    } else {
                                      _stopTracking();
                                    }
                                  },
                                  icon:
                                      !isTracking
                                          ? Icon(Icons.play_arrow)
                                          : Icon(Icons.pause),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: IconButton(
                            iconSize: 50,
                            padding: EdgeInsets.all(15),
                            style: IconButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor:
                                  isPaused
                                      ? Color(0xFFD5DBDC)
                                      : Color(0x33D5DBDC),
                              foregroundColor: Color(0xCC4B4B4B),
                            ),
                            onPressed: () => isPaused ? endTimer() : null,
                            icon: Icon(Icons.stop),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  '$minutes:$seconds',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFFFF9100),
                                  ),
                                ),
                                Text("Time"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "110",
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    color: Color(0xFFFF9100),
                                  ),
                                ),
                                Text("Cal"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 60.0),
                      // Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: CircularProgressIndicator(
                                      value: currentSeconds / maxSeconds,
                                      strokeWidth: 4,
                                      color: Color(0xFFFF9100),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: IconButton(
                                    iconSize: 53,
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
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              iconSize: 50,
                              padding: EdgeInsets.all(10),
                              style: IconButton.styleFrom(
                                shape: CircleBorder(),
                                backgroundColor:
                                    isPaused && currentSeconds == 0
                                        ? Color(0xFFD5DBDC)
                                        : Color(0x33D5DBDC),
                                foregroundColor: Color(0xCC4B4B4B),
                              ),
                              onPressed:
                                  () =>
                                      isPaused && currentSeconds == 0
                                          ? endTimer()
                                          : null,
                              icon: Icon(Icons.stop),
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
      print(currentSeconds);
      if (currentSeconds > 0) {
        currentSeconds--;
      }
      workoutSeconds++;
      minutes = (workoutSeconds ~/ 60).toString().padLeft(2, '0');
      seconds = (workoutSeconds % 60).toString().padLeft(2, '0');
      setState(() {});
      // if (currentSeconds > 0) {
      //   currentSeconds--;
      //   workoutSeconds++;
      //   minutes = (workoutSeconds ~/ 60).toString().padLeft(2, '0');
      //   seconds = (workoutSeconds % 60).toString().padLeft(2, '0');
      //   setState(() {});
      // } else {
      // timer.cancel();
      // isPaused = true;
      // final updatedWorkout = widget.workout.copyWith(isCompleted: true);
      // setState(() {});
      // _completeWorkout(updatedWorkout);
      // }
    });
  }

  void stopTimer() {
    timer?.cancel();
    isPaused = true;
    setState(() {});
  }

  void endTimer() {
    timer?.cancel();
    isPaused = true;
    final updatedWorkout = widget.workout.copyWith(
      duration: workoutSeconds,
      isCompleted: true,
    );
    setState(() {});
    _completeWorkout(updatedWorkout);
  }

  void _completeWorkout(Workout workout) {
    // BlocProvider.of<WorkoutCubit>(context).completeWorkout(workout);
    context.goNamed(RouteName.endWorkout, extra: workout);
  }

  Future<void> checkGpsStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isGpsOn = serviceEnabled;
    setState(() {
      isGpsOn = serviceEnabled;
      if (!serviceEnabled) {
        locationStatus = "GPS is OFF. Please enable location services.";
      } else {
        locationStatus = "Waiting to start tracking...";
      }
    });

    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationStatus = "Location permissions are denied. Cannot track";
          });
        }
      }
    }
  }

  void startTracking() async {
    if (!isGpsOn) {
      _showSnackBar("GPS is off. Please enable");
      return;
    }
    setState(() {
      isPaused = !isPaused;
      isTracking = true;
      locationStatus = "Tracking...";
      lastPosition = null;
    });

    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        if (lastPosition != null) {
          double distanceInMeter = Geolocator.distanceBetween(
            lastPosition!.latitude,
            lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          totalDistance += distanceInMeter;
        }
        lastPosition = position;
        // TODO: lat and long for debug. Remove it for production
        locationStatus =
            "(Debug) Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}";
      });
    });
  }

  void _stopTracking() {
    positionStreamSubscription?.cancel(); // Cancel the stream subscription
    setState(() {
      isPaused = true;
      isTracking = false;
      locationStatus = "Tracking stopped.";
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
