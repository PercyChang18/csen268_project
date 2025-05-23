import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EndWorkoutPage extends StatelessWidget {
  const EndWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final int duration = extra['duration'] ?? 0;
    final int calories = extra['calories'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Duration: $duration seconds', style: const TextStyle(fontSize: 20)),
            Text('Calories burned: $calories kcal', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to Home'),
            )
          ],
        ),
      ),
    );
  }
}
