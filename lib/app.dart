import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'navigation/main_shell.dart';

class BeautifulTrackerApp extends StatelessWidget {
  const BeautifulTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
