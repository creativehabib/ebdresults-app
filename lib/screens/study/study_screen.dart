import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // AppBar এখন থিম থেকে অটোমেটিক কালার নেবে
      appBar: AppBar(
        title: const Text("Study Materials"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        children: [
          // ================= ১. পরীক্ষা প্রস্তুতি সেকশন =================
          _buildSectionHeader(context, "Exam Preparation"),

          _buildStudyItem(
            context,
            icon: Icons.auto_stories,
            title: "BCS Preparation",
            subtitle: "বিসিএস প্রিলি ও রিটেন গাইড",
            color: Colors.blue,
            onTap: () {},
          ),

          _buildStudyItem(
            context,
            icon: Icons.account_balance,
            title: "Bank Job Special",
            subtitle: "সরকারি ও বেসরকারি ব্যাংক প্রস্তুতি",
            color: Colors.teal,
            onTap: () {},
          ),

          _buildStudyItem(
            context,
            icon: Icons.school,
            title: "Primary Teacher",
            subtitle: "প্রাথমিক শিক্ষক নিয়োগ গাইড",
            color: Colors.orange,
            onTap: () {},
          ),

          const Divider(indent: 16, endIndent: 16, height: 30),

          // ================= ২. রিসোর্স সেকশন =================
          _buildSectionHeader(context, "Resources"),

          _buildStudyItem(
            context,
            icon: Icons.picture_as_pdf,
            title: "PDF Notes & Books",
            subtitle: "লেকচার শিট ও গুরুত্বপূর্ণ বই",
            color: Colors.redAccent,
            onTap: () {},
          ),

          _buildStudyItem(
            context,
            icon: Icons.quiz,
            title: "Daily MCQ Practice",
            subtitle: "প্রতিদিনের কুইজ টেস্ট",
            color: Colors.purple,
            onTap: () {},
          ),

          _buildStudyItem(
            context,
            icon: Icons.history_edu,
            title: "Previous Questions",
            subtitle: "বিগত বছরের সকল প্রশ্নের সমাধান",
            color: Colors.indigo,
            onTap: () {},
          ),

          _buildStudyItem(
            context,
            icon: Icons.language,
            title: "General Knowledge",
            subtitle: "সাম্প্রতিক বিশ্ব ও বাংলাদেশ",
            color: Colors.green,
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // সেকশন হেডার বিল্ডার
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // স্টাডি আইটেম বিল্ডার (কার্ড স্টাইল)
  Widget _buildStudyItem(BuildContext context,
      {required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: isDark ? 0 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: Colors.white10, width: 1) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}