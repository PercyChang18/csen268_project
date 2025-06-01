part of 'workout_cubit.dart';

@immutable
sealed class WorkoutState {}

final class WorkoutInitial extends WorkoutState {}

final class WorkoutLoading extends WorkoutState {}

final class WorkoutsLoaded extends WorkoutState {
  final List<Workout> workouts;

  WorkoutsLoaded({required this.workouts});
}

class WorkoutsError extends WorkoutState {
  final String message;
  WorkoutsError({required this.message});
}

final class TestView extends WorkoutState {}
