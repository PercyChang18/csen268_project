// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Workout {
  final String title;
  final String startImage;
  final String endImage;
  final String description;
  final int duration;
  final int calories;
  bool isCompleted;

  Workout({
    required this.title,
    required this.startImage,
    required this.endImage,
    required this.description,
    required this.duration,
    required this.calories,
    this.isCompleted = false,
  });

  Workout copyWith({
    String? title,
    String? startImage,
    String? endImage,
    String? description,
    int? duration,
    int? calories,
    bool? isCompleted,
  }) {
    return Workout(
      title: title ?? this.title,
      startImage: startImage ?? this.startImage,
      endImage: endImage ?? this.endImage,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'startImage': startImage,
      'endImage': endImage,
      'description': description,
      'duration': duration,
      'calories': calories,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      title: map['title'] as String,
      startImage: map['startImage'] as String,
      endImage: map['endImage'] as String,
      description: map['description'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Workout.fromJson(String source) =>
      Workout.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Workout(title: $title, startImage: $startImage, endImage: $endImage, description: $description, duration: $duration, calories: $calories)';
  }

  @override
  bool operator ==(covariant Workout other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.startImage == startImage &&
        other.endImage == endImage &&
        other.description == description &&
        other.duration == duration &&
        other.calories == calories;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        startImage.hashCode ^
        endImage.hashCode ^
        description.hashCode ^
        duration.hashCode ^
        calories.hashCode;
  }
}
