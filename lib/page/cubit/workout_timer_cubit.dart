import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'workout_timer_state.dart';

class WorkoutTimerCubit extends Cubit<WorkoutTimerState> {
  WorkoutTimerCubit() : super(WorkoutTimerInitial());
}
