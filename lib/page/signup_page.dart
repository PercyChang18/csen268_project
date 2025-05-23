import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> {
  String? name;
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
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
                      name = value;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
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
                  ElevatedButton(onPressed: () {}, child: Text("Signup")),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Already have an account? Login'),
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
