import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Study Materials"),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text("PDF Notes"),
          ),

          ListTile(
            leading: Icon(Icons.quiz),
            title: Text("MCQ Practice"),
          ),

          ListTile(
            leading: Icon(Icons.history_edu),
            title: Text("Previous Questions"),
          ),

        ],

      ),

    );
  }
}