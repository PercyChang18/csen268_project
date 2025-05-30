import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/end_workout_page.dart';
import 'package:csen268_project/pages/log_page.dart';
import 'package:csen268_project/pages/personal_info_page.dart';
import 'package:csen268_project/pages/start_workout_page.dart';
import 'package:csen268_project/pages/welcome_page.dart';
import 'package:csen268_project/pages/workout_home_page.dart';
import 'package:csen268_project/utilities/stream_to_listenable.dart';
import 'package:csen268_project/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/sign_in_page.dart';

class RouteName {
  static const home = 'home';
  // main is just a name for routing logic
  static const main = 'main';
  static const log = 'log';
  static const startWorkout = 'startWorkout';
  static const endWorkout = 'endWorkout';
  static const signIn = 'signIn';
  static const welcome = 'welcome';
  static const personalInfo = 'personalInfo';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Root",
);
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Shell",
);

GoRouter router(dynamic authenticationBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/signIn',
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) async {
      if (authenticationBloc.state is AuthenticationNotSignedInState &&
          (!(state.fullPath?.startsWith("/signIn") ?? false))) {
        return "/signIn";
      } else {
        if ((state.fullPath?.startsWith("/signIn") ?? false) &&
            authenticationBloc.state is AuthenticationSignedInState) {
          return "/welcome";
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/signIn',
        name: RouteName.signIn,
        builder: (context, state) {
          return const SignInPage();
        },
      ),
      GoRoute(
        path: '/welcome',
        name: RouteName.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/',
        name: RouteName.main,
        builder: (context, state) {
          return const WorkoutHomePage();
        },
        routes: [
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (context, state, child) {
              return ScaffoldWithNavBar(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'home',
                name: RouteName.home,
                builder: (context, state) => const WorkoutHomePage(),
                routes: [
                  GoRoute(
                    path: 'startWorkout',
                    name: RouteName.startWorkout,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final Workout? workout = state.extra as Workout?;
                      if (workout == null) {
                        print("No workout");
                      }
                      return StartWorkoutPage(workout: workout!);
                    },
                  ),
                  GoRoute(
                    path: 'endtWorkout',
                    name: RouteName.endWorkout,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final Workout? workout = state.extra as Workout?;
                      if (workout == null) {
                        print("No workout");
                      }
                      return EndWorkoutPage(workout: workout!);
                    },
                  ),
                  GoRoute(
                    path: 'personalInfo',
                    name: RouteName.personalInfo,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PersonalInfoPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'log',
                name: RouteName.log,
                builder: (context, state) => const LogPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
