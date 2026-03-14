import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ebdresults/screens/about_us_screen.dart';
import '../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // থিম প্রোভাইডার এক্সেস করা হলো
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ================= ১. অ্যাপ কাস্টমাইজেশন সেকশন =================
          _buildSectionHeader(context, 'Customization'),

          // ডার্ক মোড সুইচ অপশন
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: theme.primaryColor),
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'ডার্ক মোড বর্তমানে অন' : 'লাইট মোড বর্তমানে অফ'),
            value: isDark,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {
              // থিম পরিবর্তন করার লজিক
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          const Divider(),

          // ================= ২. নোটিফিকেশন সেকশন =================
          _buildSectionHeader(context, 'Notifications'),

          SwitchListTile(
            secondary: Icon(Icons.notifications_active_outlined, color: theme.primaryColor),
            title: const Text('Push Notifications'),
            subtitle: const Text('নতুন চাকরির আপডেট সবার আগে পান'),
            value: _notificationsEnabled,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          const Divider(),

          // ================= ৩. সাপোর্ট এবং ইনফো সেকশন =================
          _buildSectionHeader(context, 'Support & Info'),

          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),

          _buildSettingsItem(
            context,
            icon: Icons.share_outlined,
            title: 'Invite Friends',
            onTap: () {
              Share.share('সবচেয়ে দ্রুত চাকরির আপডেট পেতে আমাদের অ্যাপটি ডাউনলোড করুন: https://play.google.com/store/apps/details?id=com.ebdresults.app');
            },
          ),

          _buildSettingsItem(
            context,
            icon: Icons.star_border_rounded,
            title: 'Rate App',
            onTap: () {
              // প্লে স্টোর লিঙ্ক ওপেন করার লজিক এখানে হবে
            },
          ),

          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // প্রাইভেসি পলিসি লিঙ্ক ওপেন হবে
            },
          ),

          const SizedBox(height: 40),

          // ================= ৪. ফুটার (ভার্সন ইনফো) =================
          Center(
            child: Column(
              children: [
                Text(
                  'JOB NEWS PORTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // সেকশন হেডার বিল্ডার
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // সেটিংস আইটেম বিল্ডার
  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15
        ),
      ),
      trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.white24 : Colors.grey.shade400
      ),
      onTap: onTap,
    );
  }
}