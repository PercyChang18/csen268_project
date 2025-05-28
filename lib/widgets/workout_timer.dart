import 'dart:async';

import 'package:flutter/material.dart';

class WorkoutTimer extends StatefulWidget {
  const WorkoutTimer({super.key});

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  Timer? timer;
  int maxSeconds = 120;
  int currentSeconds = 120;
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
    return Column(
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
                  icon: isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
                ),
              ),
            ],
          ),
        ),
      ],
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
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    isPaused = true;
    setState(() {});
  }
}
