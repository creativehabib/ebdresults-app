import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/bottom_nav.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD Student Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BottomNav(),
    );
  }
}