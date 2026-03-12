import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/jobs/job_screen.dart';
import '../screens/results/result_screen.dart';
import '../screens/study/study_screen.dart';
import '../screens/more/more_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  int index = 0;

  final screens = [
    const HomeScreen(),
    const ResultScreen(),
    const JobScreen(),
    const StudyScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: index,

        onTap: (i){
          setState(() {
            index = i;
          });
        },

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: "Results"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: "Jobs"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Study"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: "More"
          ),

        ],
      ),
    );
  }
}