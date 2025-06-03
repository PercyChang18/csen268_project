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
            Expanded(
              child: Text(
                workout.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B3B3B),
                ),
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.visible,
              ),
            ),
            SizedBox(height: 15.0),
            if (workout.isCompleted)
              Icon(Icons.check, color: Colors.black, size: 40),
          ],
        ),
      ),
    );
  }
}
