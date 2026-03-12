import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {

  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("More"),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
          ),

          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
          ),

          ListTile(
            leading: Icon(Icons.share),
            title: Text("Share App"),
          ),

          ListTile(
            leading: Icon(Icons.star),
            title: Text("Rate App"),
          ),

        ],

      ),

    );
  }
}