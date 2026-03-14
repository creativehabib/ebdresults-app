import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ebdresults/screens/favorite_jobs_screen.dart';
import 'package:ebdresults/screens/job_categories_screen.dart';
import 'package:ebdresults/screens/settings_screen.dart';
import 'package:ebdresults/screens/about_us_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ================= ড্রয়ার হেডার =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xffef9829), // আপনার অ্যাপের প্রাইমারি কালার
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // লোগো বা আইকন
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'JOB',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xff5c55a5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Job News Portal',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find your dream job easily',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // ================= ড্রয়ার মেনু আইটেম =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // ================= Category menu =================
                _buildDrawerItem(
                  icon: Icons.category_outlined,
                  title: 'Job Categories',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JobCategoriesScreen()),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.favorite_border,
                  title: 'Favorite Jobs',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoriteJobsScreen()),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: Colors.black12),
                ),

                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  onTap: () async {
                    Navigator.pop(context);
                    // শেয়ার করার লজিক
                    final String shareText = 'সবচেয়ে দ্রুত আপডেট চাকরির খবর পেতে ডাউনলোড করুন আমাদের অ্যাপ:\nhttps://play.google.com/store/apps/details?id=com.your.app.id'; // এখানে আপনার আসল প্লে স্টোর লিংক দেবেন
                    await Share.share(shareText, subject: 'Job News Portal App');
                  },
                ),
              ],
            ),
          ),

          // ================= ড্রয়ার ফুটার =================
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // মেনু আইটেম বানানোর জন্য একটি ছোট ফাংশন
  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}