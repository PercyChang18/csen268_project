import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _error;
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  TextFormField(
                    cursorColor: Color(0xFFFF9100),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                    ),
                    validator: (value) {
                      // Also you can use value.trim() to avoid full of spaces...
                      if (value == null ||
                          value.isEmpty ||
                          value.trim() == "") {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    cursorColor: Color(0xFFFF9100),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                    ),
                    validator: (value) {
                      // Also you can use value.trim() to avoid full of spaces...
                      if (value == null ||
                          value.isEmpty ||
                          value.trim() == "") {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value;
                    },
                  ),
                  SizedBox(height: 30),
                  // if (_error != null)
                  //   Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text("Login"),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text('Don\'t have an account? Sign up'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
