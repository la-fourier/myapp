import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task_item.dart';

/// Result of the planning algorithm.
class PlanResult {
  final List<Appointment> generatedAppointments;
  final List<PlanWarning> warnings;

  PlanResult({required this.generatedAppointments, required this.warnings});
}

class PlanWarning {
  final String message;
  final String? relatedItemId;
  final WarningSeverity severity;

  PlanWarning({required this.message, this.relatedItemId, this.severity = WarningSeverity.warning});
}

enum WarningSeverity { info, warning, critical }

class PlannerAlgorithmService {
  /// Plan a single day using greedy scheduling.
  /// [existingAppointments] are already fixed in the calendar.
  /// [tasks] are open tasks that need scheduling.
  /// [habits] are habits that need to be fit in.
  /// [day] is the day to plan for.
  PlanResult planDay({
    required DateTime day,
    required List<Appointment> existingAppointments,
    required List<TaskItem> tasks,
    required List<Habit> habits,
    TimeOfDay dayStart = const TimeOfDay(hour: 8, minute: 0),
    TimeOfDay dayEnd = const TimeOfDay(hour: 22, minute: 0),
  }) {
    final List<Appointment> generated = [];
    final List<PlanWarning> warnings = [];

    // Build free slots for the day
    final dayStartDT = DateTime(day.year, day.month, day.day, dayStart.hour, dayStart.minute);
    final dayEndDT = DateTime(day.year, day.month, day.day, dayEnd.hour, dayEnd.minute);

    // Sort existing by start time
    final todayAppointments = existingAppointments
        .where((a) =>
            a.start.year == day.year &&
            a.start.month == day.month &&
            a.start.day == day.day &&
            !a.calculated)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    // Build free time slots
    List<_TimeSlot> freeSlots = _buildFreeSlots(dayStartDT, dayEndDT, todayAppointments);

    // Collect all schedulable items, sorted by priority (highest first), then by deadline
    final List<_SchedulableItem> items = [];

    for (final task in tasks) {
      if (task is Task && task.deadline != null) {
        items.add(_SchedulableItem(
          id: task.id,
          name: task.name,
          duration: task.duration,
          priority: task.priority,
          deadline: task.deadline,
          categoryId: task.categoryId,
          preferredStart: null,
          preferredEnd: null,
          type: _ItemType.task,
        ));
      }
    }

    for (final habit in habits) {
      items.add(_SchedulableItem(
        id: habit.id,
        name: habit.name,
        duration: Duration(minutes: ((habit.minLength.inMinutes + habit.maxLength.inMinutes) / 2).round()),
        priority: habit.priority,
        deadline: null,
        categoryId: habit.categoryId,
        preferredStart: habit.preferredStartTime,
        preferredEnd: habit.preferredEndTime,
        type: _ItemType.habit,
      ));
    }

    // Sort: higher priority first, then earlier deadline
    items.sort((a, b) {
      final pCompare = b.priority.compareTo(a.priority);
      if (pCompare != 0) return pCompare;
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      if (a.deadline != null) return -1;
      if (b.deadline != null) return 1;
      return 0;
    });

    // Greedy: try to fit each item into the best slot
    for (final item in items) {
      bool placed = false;

      // Find the best slot (prefer time window if specified)
      _TimeSlot? bestSlot;
      int bestSlotIndex = -1;

      for (int i = 0; i < freeSlots.length; i++) {
        final slot = freeSlots[i];
        if (slot.duration >= item.duration) {
          if (item.preferredStart != null || item.preferredEnd != null) {
            final prefStart = item.preferredStart != null
                ? DateTime(day.year, day.month, day.day, item.preferredStart!.hour, item.preferredStart!.minute)
                : dayStartDT;
            final prefEnd = item.preferredEnd != null
                ? DateTime(day.year, day.month, day.day, item.preferredEnd!.hour, item.preferredEnd!.minute)
                : dayEndDT;

            // Check if slot overlaps with preferred window
            if (slot.start.isBefore(prefEnd) && slot.end.isAfter(prefStart)) {
              bestSlot = slot;
              bestSlotIndex = i;
              break;
            }
          } else {
            bestSlot = slot;
            bestSlotIndex = i;
            break;
          }
        }
      }

      if (bestSlot != null && bestSlotIndex >= 0) {
        // Place item at the start of the best slot, respecting preferred time
        DateTime appointmentStart = bestSlot.start;
        if (item.preferredStart != null) {
          final prefDT = DateTime(day.year, day.month, day.day, item.preferredStart!.hour, item.preferredStart!.minute);
          if (prefDT.isAfter(bestSlot.start) && prefDT.isBefore(bestSlot.end)) {
            appointmentStart = prefDT;
          }
        }
        final appointmentEnd = appointmentStart.add(item.duration);

        if (!appointmentEnd.isAfter(bestSlot.end)) {
          generated.add(Appointment(
            title: item.name,
            start: appointmentStart,
            end: appointmentEnd,
            calculated: true,
            sourceId: item.id,
          ));
          placed = true;

          // Update free slots
          freeSlots.removeAt(bestSlotIndex);
          if (appointmentStart.isAfter(bestSlot.start)) {
            freeSlots.insert(bestSlotIndex, _TimeSlot(bestSlot.start, appointmentStart));
          }
          if (appointmentEnd.isBefore(bestSlot.end)) {
            freeSlots.insert(
              appointmentStart.isAfter(bestSlot.start) ? bestSlotIndex + 1 : bestSlotIndex,
              _TimeSlot(appointmentEnd, bestSlot.end),
            );
          }
        }
      }

      if (!placed) {
        warnings.add(PlanWarning(
          message: 'Could not schedule "${item.name}" on ${day.day}.${day.month}.',
          relatedItemId: item.id,
          severity: item.deadline != null && item.deadline!.isBefore(day.add(const Duration(days: 3)))
              ? WarningSeverity.critical
              : WarningSeverity.warning,
        ));
      }
    }

    return PlanResult(generatedAppointments: generated, warnings: warnings);
  }

  List<_TimeSlot> _buildFreeSlots(DateTime start, DateTime end, List<Appointment> booked) {
    final slots = <_TimeSlot>[];
    DateTime cursor = start;

    for (final appt in booked) {
      if (appt.start.isAfter(cursor)) {
        slots.add(_TimeSlot(cursor, appt.start));
      }
      if (appt.end.isAfter(cursor)) {
        cursor = appt.end;
      }
    }

    if (cursor.isBefore(end)) {
      slots.add(_TimeSlot(cursor, end));
    }
    return slots;
  }
}

class _TimeSlot {
  final DateTime start;
  final DateTime end;
  Duration get duration => end.difference(start);
  _TimeSlot(this.start, this.end);
}

class _SchedulableItem {
  final String id;
  final String name;
  final Duration duration;
  final int priority;
  final DateTime? deadline;
  final String? categoryId;
  final TimeOfDay? preferredStart;
  final TimeOfDay? preferredEnd;
  final _ItemType type;

  _SchedulableItem({
    required this.id,
    required this.name,
    required this.duration,
    required this.priority,
    this.deadline,
    this.categoryId,
    this.preferredStart,
    this.preferredEnd,
    required this.type,
  });
}

enum _ItemType { task, habit }
