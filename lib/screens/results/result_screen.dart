import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Results"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        children: [
          // ================= ১. সরকারি চাকরির রেজাল্ট =================
          _buildSectionHeader(context, "Job Exam Results"),

          _buildResultItem(
            context,
            icon: Icons.assignment_turned_in_outlined,
            title: "Job Circular Results",
            subtitle: "সকল সরকারি ও বেসরকারি চাকরির পরীক্ষার ফলাফল",
            color: Colors.indigo,
            onTap: () {},
          ),

          _buildResultItem(
            context,
            icon: Icons.person_search_outlined,
            title: "NTRCA Results",
            subtitle: "বেসরকারি শিক্ষক নিবন্ধন পরীক্ষার ফলাফল",
            color: Colors.blueAccent,
            onTap: () {},
          ),

          _buildResultItem(
            context,
            icon: Icons.how_to_reg_outlined,
            title: "Primary Teacher Results",
            subtitle: "প্রাথমিক শিক্ষক নিয়োগ পরীক্ষার রেজাল্ট",
            color: Colors.green,
            onTap: () {},
          ),

          const Divider(indent: 16, endIndent: 16, height: 30),

          // ================= ২. শিক্ষা বোর্ডের রেজাল্ট =================
          _buildSectionHeader(context, "Academic & Board Results"),

          _buildResultItem(
            context,
            icon: Icons.school_outlined,
            title: "SSC / HSC / Jsc Result",
            subtitle: "সকল শিক্ষা বোর্ডের পাবলিক পরীক্ষার ফলাফল",
            color: Colors.orange,
            onTap: () {},
          ),

          _buildResultItem(
            context,
            icon: Icons.account_balance_outlined,
            title: "National University (NU)",
            subtitle: "অনার্স, মাস্টার্স ও ডিগ্রি পরীক্ষার রেজাল্ট",
            color: Colors.teal,
            onTap: () {},
          ),

          _buildResultItem(
            context,
            icon: Icons.workspace_premium_outlined,
            title: "Admission Results",
            subtitle: "বিশ্ববিদ্যালয় ভর্তি পরীক্ষার রেজাল্ট ও মেধা তালিকা",
            color: Colors.purple,
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

  // রেজাল্ট আইটেম বিল্ডার (কার্ড স্টাইল)
  Widget _buildResultItem(BuildContext context,
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
        borderRadius: BorderRadius.circular(15),
        side: isDark ? const BorderSide(color: Colors.white10, width: 1) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}