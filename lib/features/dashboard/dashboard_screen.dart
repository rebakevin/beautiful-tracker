import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Dashboard',
      child: EmptyState(
        icon: Icons.dashboard_outlined,
        message: 'Project overview will appear here.',
      ),
    );
  }
}
