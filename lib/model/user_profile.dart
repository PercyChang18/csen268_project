// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String? gender;
  double? weight;
  double? height;
  int? age;
  String? name;
  String? reminderTime;
  List<String> purposes;
  List<String> availableEquipments;

  UserProfile({
    this.name,
    this.gender,
    this.weight,
    this.height,
    this.age,
    this.reminderTime,
    List<String>? purposes,
    List<String>? availableEquipments,
  }) : purposes = purposes ?? [],
       availableEquipments = availableEquipments ?? [];

  // store information to firestore
  Map<String, dynamic> toFireStore() {
    return {
      if (gender != null) "gender": gender,
      if (weight != null) "weight": weight,
      if (height != null) "height": height,
      if (age != null) "age": age,
      if (name != null) "name": name,
      if (reminderTime != null) "reminderTime": reminderTime,
      "purpose": purposes,
      "availableEquipment": availableEquipments,
    };
  }

  // get information from firestore
  factory UserProfile.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserProfile(
      gender: data?["gender"],
      weight: data?["weight"],
      height: data?["height"],
      age: data?["age"],
      name: data?["name"],
      reminderTime: data?["reminderTime"],
      purposes: List<String>.from(data?["purpose"] ?? []),
      availableEquipments: List<String>.from(data?["availableEquipment"] ?? []),
    );
  }
}
