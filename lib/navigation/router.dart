import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/page/home_page.dart';
import 'package:csen268_project/page/log_page.dart';
import 'package:csen268_project/page/personal_info_page.dart';
import 'package:csen268_project/page/start_workout_page.dart';
import 'package:csen268_project/page/welcome_page.dart';
import 'package:csen268_project/utilities/stream_to_listenable.dart';
import 'package:csen268_project/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../page/login_page.dart';
import '../page/signup_page.dart';

class RouteName {
  static const home = 'home';
  static const main = 'main';
  static const log = 'log';
  static const startWorkout = 'startWorkout';
  static const endWorkout = 'endWorkout';
  static const signup = 'signup';
  static const login = 'login';
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
    // TODO: Change initial location to login after development
    initialLocation: '/home',
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) async {
      if (authenticationBloc.state is AuthenticationLoggedOut &&
          (!(state.fullPath?.startsWith("/login") ?? false))) {
        return "/login";
      } else {
        if ((state.fullPath?.startsWith("/login") ?? false) &&
            authenticationBloc.state is AuthenticationLoggedIn) {
          return "/home";
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: RouteName.login,
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/signup',
        name: RouteName.signup,
        builder: (context, state) => const SignupPage(),
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
          return const HomePage();
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
                builder: (context, state) => const HomePage(),
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
