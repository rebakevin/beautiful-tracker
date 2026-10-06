import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Team Members',
      child: EmptyState(
        icon: Icons.people_outline,
        message: 'No team members yet.',
      ),
    );
  }
}
