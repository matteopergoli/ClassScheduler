// lib/data/models/period_template_model.dart
//
// User-owned period template stored at:
//   /users/{uid}/periodTemplates/{templateId}
//
// Plain Dart — no freezed, no build_runner required.
// toJson/fromJson are hand-written and match Firestore exactly.

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Slot ──────────────────────────────────────────────────────────────────────

class PeriodTemplateSlot {
  final String type;      // 'LESSON' | 'BREAK'
  final String? name;     // required when type == 'BREAK'
  final String startTime; // 'HH:mm'
  final String endTime;   // 'HH:mm'

  const PeriodTemplateSlot({
    required this.type,
    this.name,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'type':      type,
        'name':      name,
        'startTime': startTime,
        'endTime':   endTime,
      };

  factory PeriodTemplateSlot.fromJson(Map<String, dynamic> j) =>
      PeriodTemplateSlot(
        type:      j['type']      as String,
        name:      j['name']      as String?,
        startTime: j['startTime'] as String,
        endTime:   j['endTime']   as String,
      );
}

// ── Template ──────────────────────────────────────────────────────────────────

class PeriodTemplateModel {
  final String id;
  final String name;
  final List<PeriodTemplateSlot> slots;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PeriodTemplateModel({
    required this.id,
    required this.name,
    required this.slots,
    required this.createdAt,
    required this.updatedAt,
  });

  PeriodTemplateModel copyWith({
    String? id,
    String? name,
    List<PeriodTemplateSlot>? slots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PeriodTemplateModel(
        id:        id        ?? this.id,
        name:      name      ?? this.name,
        slots:     slots     ?? this.slots,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'name':      name,
        'slots':     slots.map((s) => s.toJson()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory PeriodTemplateModel.fromJson(Map<String, dynamic> j, String id) =>
      PeriodTemplateModel(
        id:        id,
        name:      j['name'] as String,
        slots: (j['slots'] as List<dynamic>)
            .map((s) =>
                PeriodTemplateSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: (j['createdAt'] as Timestamp).toDate(),
        updatedAt: (j['updatedAt'] as Timestamp).toDate(),
      );
}
