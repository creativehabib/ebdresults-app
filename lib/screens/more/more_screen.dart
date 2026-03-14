import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // ইউআরএল বা সোশ্যাল লিংক ওপেন করার ফাংশন
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("More Options"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        children: [
          // ================= ১. সোশ্যাল কমিউনিটি সেকশন =================
          _buildSectionHeader(context, "Community & Support"),

          _buildMoreItem(
            context,
            icon: Icons.facebook,
            title: "Facebook Group",
            subtitle: "আমাদের কমিউনিটিতে যোগ দিন",
            color: const Color(0xff1877F2),
            onTap: () => _launchUrl('https://facebook.com/groups/yourgroup'),
          ),

          _buildMoreItem(
            context,
            icon: Icons.play_circle_fill,
            title: "YouTube Channel",
            subtitle: "চাকরির প্রস্তুতির ভিডিও টিউটোরিয়াল",
            color: const Color(0xffFF0000),
            onTap: () => _launchUrl('https://youtube.com/yourchannel'),
          ),

          _buildMoreItem(
            context,
            icon: Icons.email_outlined,
            title: "Contact Us",
            subtitle: "সরাসরি আমাদের ইমেইল করুন",
            color: Colors.blueGrey,
            onTap: () => _launchUrl('mailto:info@ebdresults.com'),
          ),

          const Divider(indent: 16, endIndent: 16, height: 30),

          // ================= ২. অ্যাপ ইনফো এবং লিগ্যাল =================
          _buildSectionHeader(context, "App Info & Legal"),

          _buildMoreItem(
            context,
            icon: Icons.info_outline,
            title: "About App",
            subtitle: "অ্যাপ সম্পর্কে বিস্তারিত জানুন",
            color: theme.primaryColor,
            onTap: () {},
          ),

          _buildMoreItem(
            context,
            icon: Icons.share_outlined,
            title: "Share App",
            subtitle: "বন্ধুদের সাথে অ্যাপটি শেয়ার করুন",
            color: Colors.teal,
            onTap: () {
              Share.share('সবচেয়ে দ্রুত চাকরির আপডেট পেতে আমাদের অ্যাপটি ডাউনলোড করুন: https://play.google.com/store/apps/details?id=com.ebdresults.app');
            },
          ),

          _buildMoreItem(
            context,
            icon: Icons.star_outline_rounded,
            title: "Rate Us",
            subtitle: "প্লে-স্টোরে ৫ স্টার রিভিউ দিন",
            color: Colors.amber,
            onTap: () {},
          ),

          _buildMoreItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            subtitle: "আমাদের প্রাইভেসি পলিসি দেখে নিন",
            color: Colors.redAccent,
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // ================= ফুটার (ভার্সন ইনফো) =================
          Center(
            child: Column(
              children: [
                Text(
                  "EBD RESULTS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildMoreItem(BuildContext context,
      {required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}