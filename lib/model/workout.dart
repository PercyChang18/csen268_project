// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Workout {
  final String title;
  final String startImage;
  final String endImage;
  final String description;

  Workout({
    required this.title,
    required this.startImage,
    required this.endImage,
    required this.description,
  });

  Workout copyWith({
    String? workoutName,
    String? startImage,
    String? endImage,
    String? description,
  }) {
    return Workout(
      title: workoutName ?? this.title,
      startImage: startImage ?? this.startImage,
      endImage: endImage ?? this.endImage,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'workoutName': title,
      'startImage': startImage,
      'endImage': endImage,
      'description': description,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      title: map['workoutName'] as String,
      startImage: map['startImage'] as String,
      endImage: map['endImage'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Workout.fromJson(String source) =>
      Workout.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Workout(workoutName: $title, startImage: $startImage, endImage: $endImage, description: $description)';
  }

  @override
  bool operator ==(covariant Workout other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.startImage == startImage &&
        other.endImage == endImage &&
        other.description == description;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        startImage.hashCode ^
        endImage.hashCode ^
        description.hashCode;
  }
}
