import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/navigation/router.dart';
import 'package:csen268_project/widgets/workout_card.dart';
import 'package:csen268_project/widgets/workout_timer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../component/workout_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final stepsToday = 7450;
    final workoutMinutes = 18;
    final recommendations = [
      Workout(
        title: "Back",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
      ),
      Workout(
        title: "Chest",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
      ),
      Workout(
        title: "Abs",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
      ),
      Workout(
        title: "Abs",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('🏋️ Keep it up!'), centerTitle: true),
      body: Padding(
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
                  recommendations
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
            // WorkoutTimer(),
          ],
        ),
      ),
    );
    // const Text(
    //   '🔥 Recommended for you',
    //   style: TextStyle(fontSize: 18, color: Colors.white),
    // ),
    // const SizedBox(height: 12),
    // ...recommendations.map(
    //   (item) => WorkoutCard(
    //     title: item['title']!,
    //     description: item['desc']!,
    //     onTap: () {
    //       showDialog(
    //         context: context,
    //         builder:
    //             (_) => AlertDialog(
    //               backgroundColor: const Color(0xFF3C3C3C),
    //               title: Text(
    //                 item['title']!,
    //                 style: const TextStyle(color: Colors.white),
    //               ),
    //               content: Text(
    //                 item['desc']!,
    //                 style: const TextStyle(color: Colors.white70),
    //               ),
    //               actions: [
    //                 TextButton(
    //                   onPressed: () => context.pop(),
    //                   child: const Text('Cancel'),
    //                 ),
    //                 ElevatedButton(
    //                   onPressed: () {
    //                     context.pop(); // 关闭弹窗
    //                     context.push('/start'); // 跳转 StartWorkoutPage
    //                   },
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: Colors.orange,
    //                   ),
    //                   child: const Text('Start'),
    //                 ),
    //               ],
    //             ),
    //       );
    //     },
    //   ),
    //   ),
    // );
  }
}
