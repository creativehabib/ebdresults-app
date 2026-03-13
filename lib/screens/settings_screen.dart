import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.white, surfaceTintColor: Colors.white,),
      body: const Center(child: Text('সেটিংস অপশনগুলো এখানে থাকবে।')),
    );
  }
}