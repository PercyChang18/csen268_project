import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/firebase_options.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:csen268_project/repositories/authentication/authentication.dart';
import 'package:csen268_project/theme/theme.dart';
import 'package:csen268_project/theme/theme_cubit.dart';
import 'package:csen268_project/services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation/router.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
  print('Message notification: ${message.notification?.body}');
}

final NotificationService notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await notificationService.init();

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  const vapidKey =
      "BAwqUpTRd9APhrXMnrCzukQSZWKTO4pH7VOdn5JJX5s0VmpmCQOCYtIadAnPkKOBlQTndBkc91uj74R0BWJjid8";
  String? token;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final authenticationBloc = AuthenticationBloc();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) {
        return AuthenticationRepository();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              return authenticationBloc..add(
                AuthenticationInitializeEvent(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(context),
                ),
              );
            },
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => WorkoutCubit()..init()),
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {},
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Gym for Everyone',
                theme: myTheme,
                routerConfig: router(authenticationBloc),
              );
            },
          ),
        ),
      ),
    );
  }
}
