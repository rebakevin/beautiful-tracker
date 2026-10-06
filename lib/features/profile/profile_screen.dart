import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Profile',
      child: EmptyState(
        icon: Icons.person_outline,
        message: 'Profile details will appear here.',
      ),
    );
  }
}
