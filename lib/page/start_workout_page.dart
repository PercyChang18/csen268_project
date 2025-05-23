import 'package:csen268_project/model/workout.dart';
import 'package:flutter/material.dart';

class StartWorkoutPage extends StatelessWidget {
  const StartWorkoutPage({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    // TODO: Add the play / pause button.
    return Scaffold(
      appBar: AppBar(title: Text(workout.title), centerTitle: true),
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
                  workout.startImage,
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
                  workout.startImage,
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
                workout.description,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              SizedBox(height: 30.0),
              IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow)),
            ],
          ),
        ),
      ),
    );
  }
}
