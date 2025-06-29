import 'package:flutter/foundation.dart';

class EyeScan {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String imagePath;
  final DateTime createdAt;

  EyeScan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.imagePath,
    required this.createdAt,
  });

  factory EyeScan.fromJson(Map<String, dynamic> json) {
    return EyeScan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imagePath: json['image_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  EyeScan copyWith({
    String? id,
    String? userId,
    String? title,
    ValueGetter<String?>? description,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return EyeScan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 