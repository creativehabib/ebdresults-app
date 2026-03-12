import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {

  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Results"),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.school),
            title: Text("SSC Result"),
          ),

          ListTile(
            leading: Icon(Icons.school),
            title: Text("HSC Result"),
          ),

          ListTile(
            leading: Icon(Icons.school),
            title: Text("NU Result"),
          ),

        ],

      ),
    );
  }
}