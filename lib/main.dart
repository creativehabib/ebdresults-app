import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/screens/splash_screen.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// ১. গ্লোবাল নেভিগেটর কি (Context ছাড়া নেভিগেট করার জন্য)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ২. OneSignal ইনিশিয়ালাইজেশন
  initOneSignal();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const EbdresultsApp(),
    ),
  );
}

void initOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("89dbffbd-6156-4837-a0a8-90107b0f6cbe");
  OneSignal.Notifications.requestPermission(true);

  // নোটিফিকেশন ক্লিক হ্যান্ডলার
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;

    if (data != null && data.containsKey("post_id")) {
      String postId = data["post_id"].toString();
      _handleNotificationClick(postId);
    }
  });
}

// ৩. নোটিফিকেশন ক্লিক হ্যান্ডলার (Updated with Loading UI)
Future<void> _handleNotificationClick(String postId) async {
  // লোডিং ডায়ালগ দেখানো (ইউজার যেন বুঝতে পারে ডাটা লোড হচ্ছে)
  final context = navigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  try {
    debugPrint("Fetching post for ID: $postId");
    final response = await ApiService.fetchSingle('posts/$postId');

    // লোডিং ডায়ালগ বন্ধ করা
    if (context != null && navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }

    if (response != null) {
      final job = JobModel.fromJson(response);

      // সরাসরি ডিটেইলস পেজে নেভিগেট করা
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => JobDetailsScreen(post: job),
        ),
      );
    } else {
      debugPrint("Post data not found for ID: $postId");
    }
  } catch (e) {
    // লোডিং ডায়ালগ বন্ধ করা (এরর আসলেও)
    if (context != null && navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
    debugPrint('Error handling notification click: $e');
  }
}

class EbdresultsApp extends StatelessWidget {
  const EbdresultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Ebdresults',
      debugShowCheckedModeBanner: false,

      // থিম কনফিগারেশন
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      home: const SplashScreen(),
    );
  }
}