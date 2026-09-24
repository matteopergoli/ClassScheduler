// lib/data/repositories/schedule_repository.dart
//
// Reads and writes ScheduleModel documents and their ScheduleCell sub-collection.
// Generation writes are handled by GenerationService (ALGO-R04 atomic batch).
// This repository handles:
//   - Listing / streaming schedule versions for a school (FR-GEN-06)
//   - Loading the full cell grid for a given schedule
//   - Writing a single cell edit (drag-and-drop, FR-VIEW-04)
//   - Renaming / deleting schedule versions

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/app_models.dart';
import '../../domain/scheduler/scheduler_input.dart' as scheduler;
import 'base_repository.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final scheduleRepositoryProvider =
    Provider.family<ScheduleRepository, String>(
  (ref, schoolId) => ScheduleRepository(
    uid:      ref.watch(currentUserProvider)!.uid,
    schoolId: schoolId,
  ),
);

// ── Repository ────────────────────────────────────────────────────────────────

class ScheduleRepository extends BaseRepository {
  final String uid;
  final String schoolId;

  ScheduleRepository({required this.uid, required this.schoolId});

  CollectionReference get _schedules =>
      subCol(uid, schoolId, AppConstants.fsSchedules);

  CollectionReference _cells(String scheduleId) =>
      _schedules.doc(scheduleId).collection(AppConstants.fsScheduleCells);

  // ── Schedule version list ────────────────────────────────────────────────

  /// Stream all schedule versions for the school, most-recent first.
  Stream<List<ScheduleModel>> watchAll() => streamCollection(
        ref: _schedules,
        fromJson: (data, id) =>
            ScheduleModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) =>
            q.orderBy('generatedAt', descending: true),
      );

  Future<List<ScheduleModel>> fetchAll() => fetchCollection(
        ref: _schedules,
        fromJson: (data, id) =>
            ScheduleModel.fromJson({...data, 'id': id}),
      );

  // ── Cells ────────────────────────────────────────────────────────────────

  /// Stream all cells for [scheduleId].
  /// Returns a flat list; the UI groups by (classroomId, periodId).
  Stream<List<ScheduleCellModel>> watchCells(String scheduleId) =>
      streamCollection(
        ref: _cells(scheduleId),
        fromJson: (data, id) =>
            ScheduleCellModel.fromJson({...data, 'id': id}),
      );

  Future<List<ScheduleCellModel>> fetchCells(String scheduleId) =>
      fetchCollection(
        ref: _cells(scheduleId),
        fromJson: (data, id) =>
            ScheduleCellModel.fromJson({...data, 'id': id}),
      );

  // ── Manual cell edit (drag-and-drop) ────────────────────────────────────
  //
  // Swaps two cells atomically: clears the source, writes the subject
  // to the destination, and marks the schedule as manually edited.
  // The caller (DragDropValidator) has already verified all hard constraints.

  Future<void> swapCells({
    required String scheduleId,
    required ScheduleCellModel source,
    required ScheduleCellModel destination,
  }) async {
    final batch = db.batch();
    final cellsRef = _cells(scheduleId);
    final scheduleRef = _schedules.doc(scheduleId);

    // Write source subject → destination cell
    batch.update(cellsRef.doc(destination.id), {
      'subjectId':           source.subjectId,
      'isViolation':         false,
      'violationDescription': null,
    });

    // Clear source cell (now free)
    batch.update(cellsRef.doc(source.id), {
      'subjectId':           null,
      'isViolation':         false,
      'violationDescription': null,
    });

    // Mark schedule as manually edited (FR-VIEW-05)
    batch.update(scheduleRef, {'isManuallyEdited': true});

    await batch.commit();
  }

  // ── Single cell direct assign (used by drag-and-drop to a free slot) ────

  Future<void> moveCell({
    required String scheduleId,
    required ScheduleCellModel source,
    required String destinationCellId,
  }) async {
    final batch = db.batch();
    final cellsRef = _cells(scheduleId);

    batch.update(cellsRef.doc(destinationCellId), {
      'subjectId':           source.subjectId,
      'isViolation':         false,
      'violationDescription': null,
    });
    batch.update(cellsRef.doc(source.id), {
      'subjectId':           null,
      'isViolation':         false,
      'violationDescription': null,
    });
    batch.update(_schedules.doc(scheduleId), {'isManuallyEdited': true});

    await batch.commit();
  }

  Future<void> saveManualValidation({
    required String scheduleId,
    required scheduler.ScheduleResult result,
    required List<ScheduleCellModel> cells,
  }) async {
    final scheduleData = {
      'isManuallyEdited': true,
      'resultStatus': _statusString(result.status),
      'hardViolationCount': result.hardViolations.length,
      'softViolationCount': result.softViolations.length,
      'qualityScore': result.qualityScore,
      'teacherFreeHours': result.teacherFreeHours,
      'subjectChanges': result.subjectChanges,
    };

    final cellsRef = _cells(scheduleId);
    const batchSize = 499;
    for (var start = 0; start < cells.length; start += batchSize) {
      final end = (start + batchSize).clamp(0, cells.length);
      final batch = db.batch();
      if (start == 0) {
        batch.update(_schedules.doc(scheduleId), scheduleData);
      }
      for (var i = start; i < end; i++) {
        final cell = cells[i];
        batch.update(cellsRef.doc(cell.id), {
          'isViolation': cell.isViolation,
          'violationDescription': cell.violationDescription,
        });
      }
      await batch.commit();
    }
  }

  String _statusString(scheduler.ResultStatus status) {
    switch (status) {
      case scheduler.ResultStatus.perfect:
        return 'PERFECT';
      case scheduler.ResultStatus.softViolationsOnly:
        return 'SOFT_VIOLATIONS';
      case scheduler.ResultStatus.hardViolations:
        return 'HARD_VIOLATIONS';
    }
  }

  // ── Rename / delete ──────────────────────────────────────────────────────

  Future<void> rename(String scheduleId, String newName) =>
      _schedules.doc(scheduleId).update({'name': newName});

  /// Delete a schedule and all its cells.
  Future<void> delete(String scheduleId) async {
    // Delete cells first (Firestore does not cascade sub-collections)
    final cellSnap = await _cells(scheduleId).get();
    final batch    = db.batch();
    for (final doc in cellSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_schedules.doc(scheduleId));
    await batch.commit();
  }
}
