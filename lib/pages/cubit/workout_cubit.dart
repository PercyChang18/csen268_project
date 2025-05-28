import 'package:bloc/bloc.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/test_page.dart';
import 'package:meta/meta.dart';

part 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  List<Workout> workouts = [];
  WorkoutCubit() : super(WorkoutInitial());

  void init() async {
    workouts = [
      Workout(
        title: "Back",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
        duration: 5,
        calories: 10,
      ),
      Workout(
        title: "Chest",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
        duration: 5,
        calories: 10,
      ),

      Workout(
        title: "Abs",
        startImage: "startImage",
        endImage: "endImage",
        description: "description",
        duration: 5,
        calories: 10,
      ),
    ];
    emit(WorkoutsLoaded(workouts: workouts));
  }

  void test() {
    emit(TestView());
  }

  void completeWorkout(Workout workout) {
    final index = workouts.indexWhere((w) => w.title == workout.title);
    workouts[index] = workout;
    emit(WorkoutsLoaded(workouts: List.from(workouts)));
  }
}
