import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // সেভ করা নোটিফিকেশন সেটিংস লোড করা
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
    });
  }

  // নোটিফিকেশন অন/অফ করার লজিক
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = value;
    });

    // OneSignal সাবস্ক্রিপশন কন্ট্রোল
    if (value) {
      OneSignal.User.pushSubscription.optIn(); // নোটিফিকেশন অন
    } else {
      OneSignal.User.pushSubscription.optOut(); // নোটিফিকেশন অফ
    }

    await prefs.setBool('push_notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Customization'),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: theme.primaryColor),
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'ডার্ক মোড অন' : 'লাইট মোড অন'),
            value: isDark,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),

          const Divider(),
          _buildSectionHeader(context, 'Notifications'),

          SwitchListTile(
            secondary: Icon(Icons.notifications_active_outlined, color: theme.primaryColor),
            title: const Text('Push Notifications'),
            subtitle: const Text('নতুন চাকরির আপডেট সবার আগে পান'),
            value: _notificationsEnabled,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {
              _toggleNotifications(value);
            },
          ),

          const Divider(),
          _buildSectionHeader(context, 'Support & Info'),

          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
          ),

          _buildSettingsItem(
            context,
            icon: Icons.share_outlined,
            title: 'Invite Friends',
            onTap: () => Share.share('সবচেয়ে দ্রুত চাকরির আপডেট পেতে আমাদের অ্যাপটি ডাউনলোড করুন: https://play.google.com/store/apps/details?id=com.ebdresults.app'),
          ),

          _buildSettingsItem(
            context,
            icon: Icons.star_border_rounded,
            title: 'Rate App',
            onTap: () {},
          ),

          const SizedBox(height: 40),
          _buildFooter(isDark),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor, letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white24 : Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildFooter(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text('JOB NEWS PORTAL', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white24 : Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text('Version 1.0.0', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }
}