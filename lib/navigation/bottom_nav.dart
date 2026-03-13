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
      body: IndexedStack( // IndexedStack ব্যবহার করলে স্ক্রিন চেঞ্জ হলেও ডাটা রিলোড হবে না
        index: index,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
          });
        },
        // স্টাইল এবং কালার কনফিগারেশন
        type: BottomNavigationBarType.fixed, // ৫টি আইটেম থাকলে এটা অবশ্যই 'fixed' দিতে হবে
        backgroundColor: Colors.white, // আপনার পছন্দমতো ব্যাকগ্রাউন্ড কালার দিন
        selectedItemColor: Colors.blueAccent, // যেটা সিলেক্ট থাকবে সেটার কালার
        unselectedItemColor: Colors.grey, // যেটা সিলেক্ট থাকবে না সেটার কালার
        showUnselectedLabels: true, // আন-সিলেক্টেড লেখাগুলো দেখানোর জন্য
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // সিলেক্ট হলে আইকন চেঞ্জ হবে
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: "Results",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Study",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}