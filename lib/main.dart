import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/screens/splash_screen.dart';
import 'package:ebdresults/navigation/bottom_nav.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ১. OneSignal ইনিশিয়ালাইজেশন
  await initOneSignal();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // ২. প্রথমবার অ্যাপ ওপেন চেক করা
  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('is_first_time') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: EbdresultsApp(isFirstTime: isFirstTime),
    ),
  );
}

Future<void> initOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("89dbffbd-6156-4837-a0a8-90107b0f6cbe");

  final prefs = await SharedPreferences.getInstance();
  bool isEnabled = prefs.getBool('push_notifications_enabled') ?? true;

  if (isEnabled) {
    OneSignal.Notifications.requestPermission(true);
    OneSignal.User.pushSubscription.optIn();
  } else {
    OneSignal.User.pushSubscription.optOut();
  }

  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data != null && data.containsKey("post_id")) {
      String postId = data["post_id"].toString();
      _handleNotificationClick(postId);
    }
  });
}

Future<void> _handleNotificationClick(String postId) async {
  final context = navigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  try {
    final response = await ApiService.fetchSingle('posts/$postId');
    if (context != null && navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }

    if (response != null) {
      final job = JobModel.fromJson(response);
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => JobDetailsScreen(post: job)),
      );
    }
  } catch (e) {
    if (context != null && navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
    debugPrint('Error: $e');
  }
}

class EbdresultsApp extends StatelessWidget {
  final bool isFirstTime;
  const EbdresultsApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Ebdresults',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // লজিক: প্রথমবার হলে SplashScreen, নাহলে সরাসরি BottomNav
      home: isFirstTime ? const SplashScreen() : const BottomNav(),
    );
  }
}