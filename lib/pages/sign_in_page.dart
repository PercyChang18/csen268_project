import 'package:csen268_project/bloc/authentication_bloc.dart';
import 'package:csen268_project/widgets/logo_animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Sign In Page")),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: SignInScreen(
          providers: [EmailAuthProvider()],
          actions: [
            // AuthStateChangeAction<SignedIn>((context, state) {
            //   BlocProvider.of<AuthenticationBloc>(
            //     context,
            //   ).add(AuthenticationSignedInEvent());
            // }),
            // // hopefully this will resolve the issue
            // AuthStateChangeAction<UserCreated>((context, state) {
            //   BlocProvider.of<AuthenticationBloc>(
            //     context,
            //   ).add(AuthenticationRefreshUserEvent());
            // }
            // ),
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return LogoAnimation();
          },
        ),
      ),
    );
  }
}
