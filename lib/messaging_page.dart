import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  String installationId = "Unknown";
  String? token = "Unknown";
  @override
  void initState() {
    // TODO: implement initState
    getInstallationId();
    super.initState();
  }

  void getInstallationId() async {
    installationId = await FirebaseInstallations.instance.getId();
    token = await FirebaseMessaging.instance.getToken() ?? "Unknown";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messaging")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Installation Id",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                installationId,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton(
                child: Text("Copy to Clipboard"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: installationId));
                },
              ),
              Divider(),
              Text(
                "Messaging Token",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                token!,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              FilledButton(
                child: Text("Copy to Clipboard"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token!));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
