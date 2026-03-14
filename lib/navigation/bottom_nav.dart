import 'package:flutter/material.dart';
import 'package:ebdresults/screens/home/home_screen.dart';
import 'package:ebdresults/screens/jobs/job_screen.dart';
import 'package:ebdresults/screens/results/result_screen.dart';
import 'package:ebdresults/screens/study/study_screen.dart';
import 'package:ebdresults/screens/more/more_screen.dart';

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
    // বর্তমান থিম ডার্ক না লাইট তা চেক করার জন্য
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: Container(
        // ডার্ক মোডে হালকা বর্ডার দেওয়ার জন্য (অপশনাল)
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            setState(() {
              index = i;
            });
          },
          // ================= থিম অনুযায়ী কনফিগারেশন =================
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // থিমের অ্যাপবার কালারের সাথে মিলবে
          selectedItemColor: Theme.of(context).primaryColor, // থিমের প্রাইমারি কালার (নেভি ব্লু/পার্পল)
          unselectedItemColor: isDark ? Colors.white54 : Colors.grey.shade600,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0, // কন্টেইনারে শ্যাডো হ্যান্ডেল করা হয়েছে

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
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
      ),
    );
  }
}