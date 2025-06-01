import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/end_workout_page.dart';
import 'package:csen268_project/pages/log_page.dart';
import 'package:csen268_project/pages/personal_info_page.dart';
import 'package:csen268_project/pages/start_workout_page.dart';
import 'package:csen268_project/pages/welcome_page.dart';
import 'package:csen268_project/pages/verify_email_page.dart';
import 'package:csen268_project/pages/workout_home_page.dart';
import 'package:csen268_project/utilities/stream_to_listenable.dart';
import 'package:csen268_project/widgets/scaffold_with_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../pages/sign_in_page.dart';

class RouteName {
  static const home = 'home';
  static const main = 'main';
  static const log = 'log';
  static const startWorkout = 'startWorkout';
  static const endWorkout = 'endWorkout';
  static const signIn = 'signIn';
  static const welcome = 'welcome';
  static const personalInfo = 'personalInfo';
  static const emailVerification = 'emailVerification';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Root",
);
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Shell",
);

GoRouter router(AuthenticationBloc authenticationBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/signIn',
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) async {
      final authState = BlocProvider.of<AuthenticationBloc>(context).state;
      final isAuthenticated = authState is AuthenticationSignedInState;
      final isSigningIn = state.fullPath?.startsWith("/signIn") ?? false;
      final isWelcoming = state.fullPath?.startsWith("/welcome") ?? false;
      bool hasCompletedWelcome = false;

      if (isAuthenticated) {
        hasCompletedWelcome = authState.user.hasCompletedWelcome ?? false;
      }
      // if is not authenticated and is not at the sign in page, return sign in
      if (!isAuthenticated && !isSigningIn) {
        return "/signIn";
      }
      // if is authenticated, check if this is the first time user
      if (isAuthenticated) {
        if (isSigningIn) {
          return hasCompletedWelcome ? "/home" : "/welcome";
        } else if (!hasCompletedWelcome && !isWelcoming) {
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
        path: '/emailVerification',
        name: RouteName.emailVerification,
        builder: (context, state) => const VerifyEmailPage(),
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
                    path: 'endWorkout', // Corrected typo here
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
