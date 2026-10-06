import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/database_helper.dart';

Future<void> main() async {
  // Plugins (sqflite) need the binding before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const BeautifulTrackerApp());
}
