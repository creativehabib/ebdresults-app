import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // সোশ্যাল লিঙ্ক ওপেন করার ফাংশন
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
        title: const Text("About Us"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= ১. হেডার সেকশন (অ্যাপ লোগো ও নাম) =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // অ্যাপের লোগো (আইকন হিসেবে)
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "JOB",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Job News Portal",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Text(
                    "Version 1.0.0",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= ২. মিশন/ভিশন সেকশন =================
                  _buildSectionTitle(context, "Our Mission"),
                  const SizedBox(height: 10),
                  Text(
                    "চাকরিপ্রার্থীদের কাছে দ্রুত এবং নির্ভরযোগ্যভাবে সকল প্রকার সরকারি ও বেসরকারি চাকরির খবর পৌঁছে দেওয়াই আমাদের প্রধান লক্ষ্য। আমরা বিশ্বাস করি সঠিক সময়ে সঠিক তথ্য একজনের ক্যারিয়ার বদলে দিতে পারে।",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= ৩. ডেভেলপার প্রোফাইল সেকশন =================
                  _buildSectionTitle(context, "Developer Profile"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Habibur Rahaman",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Graphic Designer & Web Developer",
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          "একজন প্রফেশনাল গ্রাফিক ডিজাইনার এবং ওয়েব ডেভেলপার হিসেবে আমি প্রজেক্টের কনসেপ্ট থেকে শুরু করে বাস্তবায়ন পর্যন্ত দক্ষতার সাথে কাজ করি।",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        // সোশ্যাল মিডিয়া বাটন
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(
                              icon: Icons.facebook,
                              color: const Color(0xff1877F2),
                              onTap: () => _launchUrl("https://facebook.com/creativehabib"),
                            ),
                            _buildSocialIcon(
                              icon: Icons.language,
                              color: Colors.teal,
                              onTap: () => _launchUrl("https://creativehabib.com"),
                            ),
                            _buildSocialIcon(
                              icon: Icons.email,
                              color: Colors.redAccent,
                              onTap: () => _launchUrl("mailto:iamhabibnu@email.com"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSocialIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}