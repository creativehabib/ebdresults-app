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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      // ড্রয়ারের ব্যাকগ্রাউন্ড এখন থিম থেকে নেবে
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // ================= ড্রয়ার হেডার =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 25, left: 20, right: 20),
            decoration: BoxDecoration(
              // হেডারে প্রাইমারি কালার ব্যবহার করা হলো
              color: theme.primaryColor,
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
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5)
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'JOB',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: theme.primaryColor,
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
                Text(
                  'Find your dream job easily',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
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
                  context: context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),

                _buildDrawerItem(
                  context: context,
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
                  context: context,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: isDark ? Colors.white10 : Colors.black12),
                ),

                _buildDrawerItem(
                  context: context,
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
                  context: context,
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
                  context: context,
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  onTap: () async {
                    Navigator.pop(context);
                    final String shareText = 'সবচেয়ে দ্রুত চাকরির আপডেট পেতে অ্যাপটি ডাউনলোড করুন:\nhttps://play.google.com/store/apps/details?id=com.ebdresults.app';
                    await Share.share(shareText, subject: 'Job News Portal');
                  },
                ),
              ],
            ),
          ),

          // ================= ড্রয়ার ফুটার =================
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.grey,
                  fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );
  }

  // মেনু আইটেম বিল্ডার যা থিম সাপোর্ট করবে
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
          icon,
          color: isDark ? Colors.white70 : Colors.grey.shade700
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}