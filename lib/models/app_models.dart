import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AppTab { home, cycle, symptoms, exercise, feed, tips, profile }

enum CyclePhase { menstrual, follicular, ovulatory, luteal }

class QuickActionModel {
  const QuickActionModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetTab,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AppTab targetTab;
}

class PhaseLegendItem {
  const PhaseLegendItem({
    required this.title,
    required this.days,
    required this.icon,
    required this.color,
  });

  final String title;
  final String days;
  final IconData icon;
  final Color color;
}

class CalendarDayModel {
  const CalendarDayModel({
    required this.day,
    required this.phase,
    this.isSelected = false,
    this.isPlaceholder = false,
    this.isPeriodStart = false,
  });

  final int day;
  final CyclePhase phase;
  final bool isSelected;
  final bool isPlaceholder;
  final bool isPeriodStart;
}

class HistoryEntryModel {
  const HistoryEntryModel({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    this.highlightColor,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color? highlightColor;
}

class WorkoutBarModel {
  const WorkoutBarModel({
    required this.label,
    required this.heightFactor,
    this.isHidden = false,
  });

  final String label;
  final double heightFactor;
  final bool isHidden;
}

class PostModel {
  const PostModel({
    required this.author,
    required this.timeAgo,
    required this.content,
    required this.avatar,
    required this.likes,
    required this.comments,
    this.imageUrl,
  });

  final String author;
  final String timeAgo;
  final String content;
  final String avatar;
  final int likes;
  final int comments;
  final String? imageUrl;
}

class ProfileInfoItem {
  const ProfileInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class ProfileStatItem {
  const ProfileStatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class SelectableOptionModel {
  const SelectableOptionModel({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  final String keyName;
  final String label;
  final IconData icon;
  final bool isSelected;
}

class UserProfileData {
  const UserProfileData({
    required this.name,
    required this.email,
    required this.age,
    required this.weightKg,
    required this.goal,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final int age;
  final double weightKg;
  final String goal;
  final String avatarUrl;

  factory UserProfileData.initial() {
    return const UserProfileData(
      name: 'María González',
      email: 'maria.gonzalez@email.com',
      age: 28,
      weightKg: 65,
      goal: 'Equilibrio hormonal',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    );
  }

  UserProfileData copyWith({
    String? name,
    String? email,
    int? age,
    double? weightKg,
    String? goal,
    String? avatarUrl,
  }) {
    return UserProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'weightKg': weightKg,
      'goal': goal,
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfileData.fromMap(Map<String, dynamic> map) {
    return UserProfileData(
      name: map['name'] as String? ?? UserProfileData.initial().name,
      email: map['email'] as String? ?? UserProfileData.initial().email,
      age: (map['age'] as num?)?.toInt() ?? UserProfileData.initial().age,
      weightKg:
          (map['weightKg'] as num?)?.toDouble() ?? UserProfileData.initial().weightKg,
      goal: map['goal'] as String? ?? UserProfileData.initial().goal,
      avatarUrl:
          map['avatarUrl'] as String? ?? UserProfileData.initial().avatarUrl,
    );
  }
}

class CycleData {
  const CycleData({
    required this.periodStartDate,
    this.cycleLength = 28,
  });

  final DateTime periodStartDate;
  final int cycleLength;

  factory CycleData.initial() {
    return CycleData(periodStartDate: DateTime(2026, 3, 1));
  }

  Map<String, dynamic> toMap() {
    return {
      'periodStartDate': Timestamp.fromDate(periodStartDate),
      'cycleLength': cycleLength,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CycleData.fromMap(Map<String, dynamic> map) {
    final timestamp = map['periodStartDate'];
    return CycleData(
      periodStartDate: timestamp is Timestamp
          ? timestamp.toDate()
          : CycleData.initial().periodStartDate,
      cycleLength: (map['cycleLength'] as num?)?.toInt() ?? 28,
    );
  }
}

class SymptomRecordData {
  const SymptomRecordData({
    required this.date,
    required this.energyLevel,
    required this.moodKeys,
    required this.symptomKeys,
  });

  final DateTime date;
  final double energyLevel;
  final List<String> moodKeys;
  final List<String> symptomKeys;

  String get documentId =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'energyLevel': energyLevel,
      'moodKeys': moodKeys,
      'symptomKeys': symptomKeys,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory SymptomRecordData.fromMap(Map<String, dynamic> map) {
    final timestamp = map['date'];
    return SymptomRecordData(
      date: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      energyLevel: (map['energyLevel'] as num?)?.toDouble() ?? 50,
      moodKeys: List<String>.from(map['moodKeys'] as List? ?? const []),
      symptomKeys: List<String>.from(map['symptomKeys'] as List? ?? const []),
    );
  }
}

class WorkoutData {
  const WorkoutData({
    required this.id,
    required this.title,
    required this.intensity,
    required this.durationMinutes,
    required this.calories,
    required this.date,
  });

  final String id;
  final String title;
  final String intensity;
  final int durationMinutes;
  final int calories;
  final DateTime date;

  WorkoutData copyWith({
    String? id,
    String? title,
    String? intensity,
    int? durationMinutes,
    int? calories,
    DateTime? date,
  }) {
    return WorkoutData(
      id: id ?? this.id,
      title: title ?? this.title,
      intensity: intensity ?? this.intensity,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'intensity': intensity,
      'durationMinutes': durationMinutes,
      'calories': calories,
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory WorkoutData.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['date'];
    return WorkoutData(
      id: id,
      title: map['title'] as String? ?? 'Entrenamiento',
      intensity: map['intensity'] as String? ?? 'Media',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      calories: (map['calories'] as num?)?.toInt() ?? 200,
      date: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }
}

class TipHeroModel {
  const TipHeroModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.backgroundColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color backgroundColor;
}

class TipInsightModel {
  const TipInsightModel({
    required this.title,
    required this.description,
    required this.progress,
    required this.icon,
  });

  final String title;
  final String description;
  final double progress;
  final IconData icon;
}

class TipRecommendationModel {
  const TipRecommendationModel({
    required this.id,
    required this.section,
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.sectionColor,
    this.isFavorite = false,
    this.isExpanded = false,
  });

  final String id;
  final String section;
  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final Color sectionColor;
  final bool isFavorite;
  final bool isExpanded;

  TipRecommendationModel copyWith({
    bool? isFavorite,
    bool? isExpanded,
  }) {
    return TipRecommendationModel(
      id: id,
      section: section,
      title: title,
      description: description,
      icon: icon,
      tint: tint,
      sectionColor: sectionColor,
      isFavorite: isFavorite ?? this.isFavorite,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class AiTipDraft {
  const AiTipDraft({
    required this.section,
    required this.title,
    required this.description,
  });

  final String section;
  final String title;
  final String description;

  factory AiTipDraft.fromMap(Map<String, dynamic> map) {
    return AiTipDraft(
      section: map['section'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}

class AiInsightDraft {
  const AiInsightDraft({
    required this.title,
    required this.description,
    required this.progress,
  });

  final String title;
  final String description;
  final double progress;

  factory AiInsightDraft.fromMap(Map<String, dynamic> map) {
    return AiInsightDraft(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AiHeroDraft {
  const AiHeroDraft({
    required this.id,
    required this.category,
    required this.message,
  });

  final String id;
  final String category;
  final String message;

  factory AiHeroDraft.fromMap(Map<String, dynamic> map) {
    return AiHeroDraft(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? '',
      message: map['message'] as String? ?? '',
    );
  }
}

class AiTipsPayload {
  const AiTipsPayload({
    required this.heroes,
    required this.insights,
    required this.recommendations,
  });

  final List<AiHeroDraft> heroes;
  final List<AiInsightDraft> insights;
  final List<AiTipDraft> recommendations;

  factory AiTipsPayload.fromMap(Map<String, dynamic> map) {
    return AiTipsPayload(
      heroes: (map['heroes'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AiHeroDraft.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      insights: (map['insights'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AiInsightDraft.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      recommendations: (map['recommendations'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AiTipDraft.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
