import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String message;
  final String category;
  final DateTime dateTime;
  final bool active;
  final String userId;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.message,
    required this.category,
    required this.dateTime,
    this.active = true,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    String? message,
    String? category,
    DateTime? dateTime,
    bool? active,
    String? userId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      active: active ?? this.active,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'category': category,
      'dateTime': Timestamp.fromDate(dateTime),
      'active': active,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['dateTime'] as Timestamp?;
    final createdTimestamp = map['createdAt'] as Timestamp?;
    return NotificationModel(
      id: id,
      message: map['message'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      dateTime: timestamp?.toDate() ?? DateTime.now(),
      active: map['active'] as bool? ?? true,
      userId: map['userId'] as String? ?? '',
      createdAt: createdTimestamp?.toDate() ?? DateTime.now(),
    );
  }

  static const categories = ['Ciclo', 'Síntomas', 'Ejercicio', 'General'];

  String get formattedDateTime {
    final d = dateTime;
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${d.day} ${months[d.month]} ${d.year} • '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String get categoryIcon {
    switch (category) {
      case 'Ciclo':
        return '🌸';
      case 'Síntomas':
        return '💜';
      case 'Ejercicio':
        return '💪';
      default:
        return '🔔';
    }
  }
}