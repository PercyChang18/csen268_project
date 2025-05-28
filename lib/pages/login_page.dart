import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: SignInScreen(
        providers: [EmailAuthProvider()],
        actions: [AuthStateChangeAction<SignedIn>((context, state) {})],
      ),
    );
  }
}
