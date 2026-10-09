enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.label);
  final String label;
}

enum TaskStatus {
  todo('To Do'),
  inProgress('In Progress'),
  completed('Completed');

  const TaskStatus(this.label);
  final String label;
}

/// SLA status, derived automatically from a task's workflow status and due
/// date rather than chosen by the user.
enum SlaStatus {
  onTrack('On Track'),
  atRisk('At Risk'),
  overdue('Overdue'),
  completed('Completed');

  const SlaStatus(this.label);
  final String label;
}

/// A task enters "At Risk" when its deadline is within 3 days (and it
/// is not completed yet).
const int slaRiskThresholdDays = 3;

SlaStatus resolveSla({
  required TaskStatus status,
  required DateTime dueDate,
  required DateTime now,
}) {
  if (status == TaskStatus.completed) return SlaStatus.completed;

  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final daysUntilDue = due.difference(today).inDays;

  if (daysUntilDue < 0) return SlaStatus.overdue;
  if (daysUntilDue <= slaRiskThresholdDays) return SlaStatus.atRisk;
  return SlaStatus.onTrack;
}

class Task {
  const Task({
    this.id,
    required this.title,
    this.description = '',
    required this.assignee,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
  });

  final int? id; // null until the database assigns one
  final String title;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;

  SlaStatus get sla => resolveSla(status: status, dueDate: dueDate, now: DateTime.now());

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'assignee': assignee,
    'due_date': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    assignee: map['assignee'] as String,
    dueDate: DateTime.parse(map['due_date'] as String),
    priority: TaskPriority.values.byName(map['priority'] as String),
    status: TaskStatus.values.byName(map['status'] as String),
  );

  Task copyWith({
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    assignee: assignee ?? this.assignee,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
  );
}
