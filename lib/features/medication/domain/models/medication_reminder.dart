import 'package:flutter/foundation.dart';

class MedicationReminder {
  final String id;
  final String userId;
  final String medicationName;
  final String? description;
  final List<DateTime> reminderTimes;
  final List<int> daysOfWeek; // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationReminder({
    required this.id,
    required this.userId,
    required this.medicationName,
    this.description,
    required this.reminderTimes,
    required this.daysOfWeek,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      medicationName: json['medication_name'] as String,
      description: json['description'] as String?,
      reminderTimes: (json['reminder_times'] as List)
          .map((time) => DateTime.parse(time as String))
          .toList(),
      daysOfWeek: (json['days_of_week'] as List).cast<int>(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'medication_name': medicationName,
      'description': description,
      'reminder_times': reminderTimes.map((time) => time.toIso8601String()).toList(),
      'days_of_week': daysOfWeek,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MedicationReminder copyWith({
    String? id,
    String? userId,
    String? medicationName,
    ValueGetter<String?>? description,
    List<DateTime>? reminderTimes,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      description: description != null ? description() : this.description,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 