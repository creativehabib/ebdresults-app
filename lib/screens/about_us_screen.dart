import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(title: const Text('About Us'), backgroundColor: Colors.white, surfaceTintColor: Colors.white,),
      body: const Center(child: Text('অ্যাপ এবং আপনাদের সম্পর্কে তথ্য এখানে থাকবে।')),
    );
  }
}