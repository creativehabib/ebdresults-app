import 'package:flutter/material.dart';

class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Job Circular"),
      ),

      body: ListView.builder(

        itemCount: 10,

        itemBuilder: (context,index){

          return const Card(

            child: ListTile(
              title: Text("Government Job Circular"),
              subtitle: Text("Deadline: 25 March"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),

          );

        },

      ),
    );
  }
}