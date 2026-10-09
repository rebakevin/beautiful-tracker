import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/member_repository.dart';
import '../../members/member.dart' show Member;
import '../../members/widgets/member_picker_sheet.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../utils/task_date.dart';

/// Form used both to create a task and to edit an existing one.

class CreateEditTaskScreen extends StatefulWidget {
  const CreateEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TaskRepository();
  final _memberRepository = const MemberRepository();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _dateText;

  String? _assignee;
  DateTime? _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  late SlaStatus _sla;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _dueDate = t?.dueDate;
    _dateText = TextEditingController(
      text: t == null ? '' : formatTaskDate(t.dueDate),
    );
    _assignee = t?.assignee;
    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.todo;
    _sla = t?.sla ?? SlaStatus.onTrack;
  }

  Future<void> _pickAssignee(FormFieldState<String> field) async {
    List<Member> members;
    try {
      members = await _memberRepository.fetchAll();
    } catch (_) {
      members = [];
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<MemberPick>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (_) => MemberPickerSheet(
        title: 'Assign to',
        members: members,
        selected: _assignee,
      ),
    );
    final name = picked?.name;
    if (name != null) {
      setState(() => _assignee = name);
      field.didChange(name);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _dateText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,

      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dateText.text = formatTaskDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = Task(
      id: widget.task?.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      assignee: _assignee!,
      dueDate: _dueDate!,
      priority: _priority,
      status: _status,
      sla: _sla,
    );

    try {
      if (_isEditing) {
        await _repository.update(task);
      } else {
        await _repository.insert(task);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true); // true = something was saved
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the task. Try again.')),
      );
    }
  }

  InputDecoration _decoration({String? hint, Widget? suffixIcon}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger),
    );
  }

  Widget _field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }

  ButtonStyle get _segmentStyle => SegmentedButton.styleFrom(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.ink2,
    selectedBackgroundColor: AppColors.primaryTint,
    selectedForegroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.border),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Create Task'),
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              _field(
                'Task title',
                TextFormField(
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(hint: 'Enter task title'),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Title is required';
                    if (text.length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),
              _field(
                'Description',
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: _decoration(hint: 'Enter task description'),
                ),
              ),
              _field(
                'Assign to',
                FormField<String>(
                  initialValue: _assignee,
                  validator: (value) =>
                      value == null ? 'Choose who this task is for' : null,
                  builder: (field) => InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    onTap: () => _pickAssignee(field),
                    child: InputDecorator(
                      decoration: _decoration(
                        suffixIcon: const Icon(Icons.keyboard_arrow_down),
                      ).copyWith(errorText: field.errorText),
                      child: Text(
                        _assignee ?? 'Select team member',
                        style: TextStyle(
                          fontSize: 16,
                          color: _assignee == null
                              ? AppColors.muted
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _field(
                'Due date',
                TextFormField(
                  controller: _dateText,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _decoration(
                    hint: 'Select date',
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  validator: (_) =>
                      _dueDate == null ? 'Choose a due date' : null,
                ),
              ),
              _field(
                'Priority',
                SegmentedButton<TaskPriority>(
                  showSelectedIcon: false,
                  style: _segmentStyle,
                  segments: [
                    for (final p in TaskPriority.values)
                      ButtonSegment(value: p, label: Text(p.label)),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
              ),
              _field(
                'Status',
                SegmentedButton<TaskStatus>(
                  showSelectedIcon: false,
                  style: _segmentStyle,
                  segments: [
                    for (final s in TaskStatus.values)
                      ButtonSegment(value: s, label: Text(s.label)),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) => setState(() => _status = s.first),
                ),
              ),
              _field(
                'SLA status (set manually for now)',
                DropdownButtonFormField<SlaStatus>(
                  initialValue: _sla,
                  decoration: _decoration(),
                  items: [
                    for (final s in SlaStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sla = value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.field),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.field),
                        ),
                      ),
                      child: Text(_isEditing ? 'Save Changes' : 'Save Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
