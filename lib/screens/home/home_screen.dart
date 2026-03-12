import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("BD Student Hub"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(12),

        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.school),
              title: Text("Latest Results"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.work),
              title: Text("Latest Job Circular"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.article),
              title: Text("Education News"),
            ),
          ),

        ],
      ),
    );
  }
}