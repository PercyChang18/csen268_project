import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/bloc/notification_bloc/notifications_bloc.dart';
import 'package:csen268_project/firebase_options.dart';
import 'package:csen268_project/messaging_page.dart';
import 'package:csen268_project/repositories/authentication/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
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

  // if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
  //   token = await messaging.getToken(vapidKey: vapidKey);
  // } else {
  try {
    token = await messaging.getToken();
  } catch (e) {
    print("Error getting token $e");
  }
  // }
  print("Messaging token: $token");
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
    // Do whatever you need to do with this message
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) {
        return (OktaAuthenticationRepository() as AuthenticationRepository);
      },
      child: BlocProvider(
        create: (context) => NotificationsBloc()..init(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          builder: (context, child) {
            Widget _child = child ?? Container();
            return BlocListener<NotificationsBloc, NotificationsState>(
              listener: (context, state) async {
                if (state is NotificationsReceivedState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.message.notification?.title ?? "<title>"),
                          Text(state.message.notification?.body ?? "<body>"),
                          Text("Type: ${state.notificationType.name}"),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: _child,
            );
          },
          home: MessagingPage(),
        ),
      ),
    );
  }
}
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       routerConfig: router(authenticationBloc),
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFF3B3B3B), // 深色背景
//         primaryColor: const Color(0xFFFF9100), // 橙色主色调
//         // cardColor: const Color(0xFF3C3C3C), // 卡片背景
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFFD5DBDC),
//           ),
//           bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFD5DBDC)),
//           bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFD5DBDC)),
//           bodySmall: TextStyle(fontSize: 12, color: Color(0xFFD5DBDC)),
//         ),

//         inputDecorationTheme: const InputDecorationTheme(
//           labelStyle: TextStyle(color: Color(0xFFFF9100)),
//           hintStyle: TextStyle(color: Color(0xFFD5DBDC)),
//           border: UnderlineInputBorder(
//             borderSide: BorderSide(color: Color(0xFFFF9100)),
//           ),
//           enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Color(0xFFD5DBDC)),
//           ),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Color(0xFFFF9100)),
//           ),
//         ),

//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Color(0xFFFF9100),
//             foregroundColor: Color(0xFF3B3B3B),
//             textStyle: const TextStyle(fontWeight: FontWeight.bold),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         ),

//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(foregroundColor: Color(0xFFFF9100)),
//         ),

//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF3B3B3B),
//           elevation: 0,
//           titleTextStyle: TextStyle(
//             color: Color(0xFFD5DBDC),
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//           ),
//           iconTheme: IconThemeData(color: Color(0xFFD5DBDC)),
//         ),
//         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//           backgroundColor: Color(0xFF3B3B3B),
//           selectedIconTheme: IconThemeData(size: 30, color: Color(0xFFFF9100)),
//           unselectedIconTheme: IconThemeData(
//             size: 30,
//             color: Color(0xFFD5DBDC),
//           ),
//           selectedItemColor: Color(0xFFFF9100),
//           unselectedItemColor: Color(0xFFD5DBDC),
//         ),
//         iconTheme: IconThemeData(color: Color(0xFFFF9100), size: 35),
//       ),
//     );
//   }
// }
