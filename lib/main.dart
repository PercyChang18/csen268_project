import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/firebase_options.dart';
import 'package:csen268_project/model/workout.dart';
import 'package:csen268_project/pages/cubit/workout_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(await FirebaseInstallations.instance.getId());

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final authenticationBloc = AuthenticationBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutCubit()..init(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router(authenticationBloc),
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF3B3B3B),
          primaryColor: const Color(0xFFFF9100),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD5DBDC),
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFD5DBDC)),
            bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFD5DBDC)),
            bodySmall: TextStyle(fontSize: 12, color: Color(0xFFD5DBDC)),
          ),

          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Color(0xFFFF9100)),
            hintStyle: TextStyle(color: Color(0xFFD5DBDC)),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF9100)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD5DBDC)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF9100)),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9100),
              foregroundColor: Color(0xFF3B3B3B),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFFFF9100)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3B3B3B),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFD5DBDC),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Color(0xFFD5DBDC)),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF3B3B3B),
            selectedIconTheme: IconThemeData(
              size: 30,
              color: Color(0xFFFF9100),
            ),
            unselectedIconTheme: IconThemeData(
              size: 30,
              color: Color(0xFFD5DBDC),
            ),
            selectedItemColor: Color(0xFFFF9100),
            unselectedItemColor: Color(0xFFD5DBDC),
          ),
          iconTheme: IconThemeData(color: Color(0xFFFF9100), size: 35),
        ),
      ),
    );
  }
}
