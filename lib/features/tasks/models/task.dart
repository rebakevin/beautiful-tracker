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

/// SLA status. Chosen manually for now; the automatic logic comes later.
enum SlaStatus {
  onTrack('On Track'),
  atRisk('At Risk'),
  overdue('Overdue'),
  completed('Completed');

  const SlaStatus(this.label);
  final String label;
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
    this.sla = SlaStatus.onTrack,
  });

  final int? id; // null until the database assigns one
  final String title;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final SlaStatus sla;

  /// Converts the task into a row that SQLite can store.
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'assignee': assignee,
    'due_date': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'sla_status': sla.name,
  };

  /// Builds a task from a row read out of SQLite.
  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    assignee: map['assignee'] as String,
    dueDate: DateTime.parse(map['due_date'] as String),
    priority: TaskPriority.values.byName(map['priority'] as String),
    status: TaskStatus.values.byName(map['status'] as String),
    sla: SlaStatus.values.byName(map['sla_status'] as String),
  );

  /// Returns a copy with some fields changed (used when editing).
  Task copyWith({
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    SlaStatus? sla,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    assignee: assignee ?? this.assignee,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    sla: sla ?? this.sla,
  );
}
