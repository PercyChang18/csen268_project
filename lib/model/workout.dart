// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Workout {
  final String id;
  final String category;
  final String title;
  final String startImage;
  final String endImage;
  final String description;
  final int duration;
  final double calories;
  final List<String>? equipments;
  bool isCompleted;

  Workout({
    required this.id,
    required this.category,
    required this.title,
    required this.startImage,
    required this.endImage,
    required this.description,
    required this.duration,
    required this.calories,
    this.isCompleted = false,
    List<String>? equipments,
  }) : equipments = equipments ?? [];

  factory Workout.fromFirestore(String id, Map<String, dynamic> data) {
    return Workout(
      id: id,
      category: data['category'] as String? ?? 'Unnamed Category',
      title: data['title'] as String? ?? 'Unnamed Workout',
      startImage: data['startImage'] as String? ?? 'No start image',
      endImage: data['endImage'] as String? ?? 'No end image',
      description:
          data['description'] as String? ?? 'No description available.',
      duration: data['duration'] as int? ?? 0,
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      equipments: List<String>.from(data['equipments'] ?? []),
    );
  }

  Workout copyWith({
    String? id,
    String? category,
    String? title,
    String? startImage,
    String? endImage,
    String? description,
    int? duration,
    double? calories,
    List<String>? equipments,
    bool? isCompleted,
  }) {
    return Workout(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      startImage: startImage ?? this.startImage,
      endImage: endImage ?? this.endImage,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      equipments: equipments ?? this.equipments,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Workout(id: $id, category: $category, title: $title, startImage: $startImage, endImage: $endImage, description: $description, duration: $duration, calories: $calories, equipments: $equipments, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(covariant Workout other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.category == category &&
        other.title == title &&
        other.startImage == startImage &&
        other.endImage == endImage &&
        other.description == description &&
        other.duration == duration &&
        other.calories == calories &&
        listEquals(other.equipments, equipments) &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        title.hashCode ^
        startImage.hashCode ^
        endImage.hashCode ^
        description.hashCode ^
        duration.hashCode ^
        calories.hashCode ^
        equipments.hashCode ^
        isCompleted.hashCode;
  }
}
