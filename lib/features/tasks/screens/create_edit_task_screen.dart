import 'package:flutter/material.dart';

import '../../../widgets/app_sheet.dart';
import '../../../widgets/form_page.dart';
import '../../../widgets/labeled_text_field.dart';
import '../../../widgets/picker_field.dart';
import '../../../data/repositories/member_repository.dart';
import '../../members/member.dart' show Member;
import '../../members/widgets/member_picker_sheet.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../utils/task_date.dart';
import '../widgets/choice_segments.dart';

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
  }

  Future<void> _pickAssignee(FormFieldState<String> field) async {
    List<Member> members;
    try {
      members = await _memberRepository.fetchAll();
    } catch (_) {
      members = [];
    }
    if (!mounted) return;
    final picked = await showAppSheet<MemberPick>(
      context,
      isScrollControlled: true,
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: FormPage(
        title: _isEditing ? 'Edit Task' : 'Create Task',
        saveLabel: _isEditing ? 'Save Changes' : 'Save Task',
        saving: _saving,
        onSave: _save,
        children: [
          LabeledTextField(
            label: 'Task title',
            controller: _title,
            hint: 'Enter task title',
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Title is required';
              if (text.length < 3) return 'Title must be at least 3 characters';
              return null;
            },
          ),
          LabeledTextField(
            label: 'Description',
            controller: _description,
            hint: 'Enter task description',
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
          LabeledField(
            label: 'Assign to',
            child: FormField<String>(
              initialValue: _assignee,
              validator: (value) =>
                  value == null ? 'Choose who this task is for' : null,
              builder: (field) => PickerField(
                text: _assignee ?? 'Select team member',
                isPlaceholder: _assignee == null,
                errorText: field.errorText,
                onTap: () => _pickAssignee(field),
              ),
            ),
          ),
          LabeledField(
            label: 'Due date',
            child: TextFormField(
              controller: _dateText,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (_) => _dueDate == null ? 'Choose a due date' : null,
            ),
          ),
          LabeledField(
            label: 'Priority',
            child: ChoiceSegments<TaskPriority>(
              options: [for (final p in TaskPriority.values) (p, p.label)],
              selected: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
          ),
          LabeledField(
            label: 'Status',
            child: ChoiceSegments<TaskStatus>(
              options: [for (final s in TaskStatus.values) (s, s.label)],
              selected: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
          ),
        ],
      ),
    );
  }
}
