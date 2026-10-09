import 'package:beautiful_tracker/features/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 9, 15, 30);

  SlaStatus sla({required TaskStatus status, required DateTime due}) =>
      resolveSla(status: status, dueDate: due, now: now);

  test('completed workflow status always maps to completed', () {
    expect(
      sla(status: TaskStatus.completed, due: DateTime(2026, 10, 1)),
      SlaStatus.completed,
    );
    expect(
      sla(status: TaskStatus.completed, due: DateTime(2026, 10, 20)),
      SlaStatus.completed,
    );
  });

  test('not completed and past the due date is overdue', () {
    expect(
      sla(status: TaskStatus.todo, due: DateTime(2026, 10, 8)),
      SlaStatus.overdue,
    );
    expect(
      sla(status: TaskStatus.inProgress, due: DateTime(2026, 9, 30)),
      SlaStatus.overdue,
    );
  });

  test('not completed and due today is at risk (not overdue)', () {
    expect(
      sla(status: TaskStatus.todo, due: DateTime(2026, 10, 9)),
      SlaStatus.atRisk,
    );
  });

  test('not completed and due within the threshold is at risk', () {
    expect(
      sla(status: TaskStatus.inProgress, due: DateTime(2026, 10, 12)),
      SlaStatus.atRisk,
    );
  });

  test('not completed and due beyond the threshold is on track', () {
    expect(
      sla(status: TaskStatus.todo, due: DateTime(2026, 10, 13)),
      SlaStatus.onTrack,
    );
  });
}
