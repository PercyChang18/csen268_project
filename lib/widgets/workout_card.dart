import 'package:csen268_project/model/workout.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFF9100),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B3B3B),
              ),
            ),
            SizedBox(height: 15.0),
            // Icon(Icons.check, color: Colors.black, size: 40),
          ],
        ),
      ),
    );
  }
}
