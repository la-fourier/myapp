import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/task_item.dart';

void main() {
  group('Project Aggregation Logic', () {
    test('Project should aggregate properties from its tasks', () {
      final task1 = Task(
        id: 't1',
        name: 'Task 1',
        priority: 2,
        froggyness: 1,
        duration: const Duration(minutes: 30),
        deadline: DateTime(2026, 3, 10),
      );

      final task2 = Task(
        id: 't2',
        name: 'Task 2',
        priority: 4,
        froggyness: 5,
        duration: const Duration(minutes: 45),
        deadline: DateTime(2026, 3, 12),
      );

      final project = Project(
        id: 'p1',
        name: 'Project 1',
        children: [task1, task2],
      );

      expect(project.deadline, DateTime(2026, 3, 12)); // Späteste Deadline
      expect(project.priority, 3); // (2+4)/2
      expect(project.froggyness, 3); // (1+5)/2
      expect(project.duration.inMinutes, 75); // 30+45
    });

    test('Nested Project aggregation should work', () {
       final task1 = Task(
        id: 't1',
        name: 'Task 1',
        priority: 4,
        froggyness: 4,
        duration: const Duration(minutes: 60),
        deadline: DateTime(2026, 3, 20),
      );

      final subProject = Project(
        id: 'sp1',
        name: 'Sub Project',
        children: [
          Task(id: 't2', name: 'Task 2', priority: 2, froggyness: 2, duration: const Duration(minutes: 30), deadline: DateTime(2026, 3, 15)),
        ],
      );

      final rootProject = Project(
        id: 'rp1',
        name: 'Root Project',
        children: [task1, subProject],
      );

      // Root Project properties based on task1 (P4, F4, D60, Dl20) and subProject (P2, F2, D30, Dl15)
      expect(rootProject.deadline, DateTime(2026, 3, 20));
      expect(rootProject.priority, 3); // (4+2)/2
      expect(rootProject.froggyness, 3); // (4+2)/2
      expect(rootProject.duration.inMinutes, 90); // 60+30
    });
  });
}
