import 'package:flutter/material.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("ইন্টারনেট সংযোগ নেই!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("অনুগ্রহ করে আপনার কানেকশন চেক করুন।"),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: onRetry,
              child: const Text("আবার চেষ্টা করুন")
          ),
        ],
      ),
    );
  }
}