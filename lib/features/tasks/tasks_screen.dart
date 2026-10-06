import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Tasks',
      child: EmptyState(
        icon: Icons.task_alt_outlined,
        message: 'No tasks yet.',
      ),
    );
  }
}
