import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../data/repositories/member_repository.dart';
import '../../widgets/form_page.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/toast.dart';
import 'member.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.member});

  final Member? member;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _repository = const MemberRepository();
  bool _saving = false;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _nameController.text = member.name;
      _emailController.text = member.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final initials = Member.initialsFromName(name);
      final Member saved;
      if (_isEditing) {
        final existing = widget.member!;
        saved = Member(
          id: existing.id,
          name: name,
          email: email,
          initials: initials,
          taskCount: existing.taskCount,
          statuses: existing.statuses,
        );
        await _repository.update(saved);
      } else {
        final id = await _repository.insert(
          Member(
            name: name,
            email: email,
            initials: initials,
            taskCount: 0,
            statuses: const [],
          ),
        );
        saved = Member(
          id: id,
          name: name,
          email: email,
          initials: initials,
          taskCount: 0,
          statuses: const [],
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Could not save the member.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: FormPage(
        title: _isEditing ? 'Edit Member' : 'Add Member',
        saving: _saving,
        onSave: _save,
        children: [
          LabeledTextField(
            label: 'Name',
            controller: _nameController,
            hint: 'Full name',
            validator: Validators.name,
            textCapitalization: TextCapitalization.words,
          ),
          LabeledTextField(
            label: 'Email',
            controller: _emailController,
            hint: 'name@team.dev',
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
