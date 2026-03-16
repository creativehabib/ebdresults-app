import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/screens/splash_screen.dart';
import 'package:ebdresults/navigation/bottom_nav.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/models/notification_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:ebdresults/services/connectivity_service.dart';
import 'package:ebdresults/services/notification_service.dart';
import 'package:ebdresults/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// ১. গ্লোবাল নেভিগেটর কি (কনটেক্সট ছাড়া নোটিফিকেশন থেকে নেভিগেট করার জন্য)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // ফ্ল্যাটার ইঞ্জিন ইনিশিয়ালাইজেশন
  WidgetsFlutterBinding.ensureInitialized();

  // OneSignal ইনিশিয়ালাইজেশন
  await initOneSignal();

  // থিম প্রোভাইডার লোড করা
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // প্রথমবার অ্যাপ ওপেন কি না তা চেক করা
  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('is_first_time') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: EbdresultsApp(isFirstTime: isFirstTime),
    ),
  );
}

// ================= OneSignal Logic =================
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

  // ২. নোটিফিকেশন আসার সাথে সাথে অটোমেটিক সেভ করার লজিক
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final notification = event.notification;

    // additionalData থেকে postId বের করা
    final data = notification.additionalData;
    String? postIdFromData;
    if (data != null && data.containsKey("post_id")) {
      postIdFromData = data["post_id"].toString();
    }

    // ডাটা মডেল তৈরি করে লোকাল সার্ভিসে সেভ করা
    final newNotify = NotificationModel(
      id: notification.notificationId,
      title: notification.title ?? "নতুন বিজ্ঞপ্তি",
      message: notification.body ?? "",
      dateTime: DateTime.now(),
      postId: postIdFromData, // postId যুক্ত করা হয়েছে
      isRead: false,
    );

    NotificationService.addNotification(newNotify);

    // নোটিফিকেশন ডিসপ্লে করা
    event.notification.display();
  });

  // ৩. নোটিফিকেশন ক্লিক হ্যান্ডলার
  OneSignal.Notifications.addClickListener((event) {
    final notification = event.notification;
    final data = notification.additionalData;

    String? postIdFromData;
    if (data != null && data.containsKey("post_id")) {
      postIdFromData = data["post_id"].toString();
    }

    // ক্লিক করা নোটিফিকেশনটি সেভ করা
    final clickedNotify = NotificationModel(
      id: notification.notificationId,
      title: notification.title ?? "নতুন বিজ্ঞপ্তি",
      message: notification.body ?? "",
      dateTime: DateTime.now(),
      postId: postIdFromData, // postId যুক্ত করা হয়েছে
      isRead: true,
    );
    NotificationService.addNotification(clickedNotify);

    if (postIdFromData != null) {
      _handleNotificationClick(postIdFromData);
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

    // ডায়ালগ বন্ধ করা
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
    debugPrint('Notification Click Error: $e');
  }
}

// ================= Main App Widget =================
class EbdresultsApp extends StatefulWidget {
  final bool isFirstTime;
  const EbdresultsApp({super.key, required this.isFirstTime});

  @override
  State<EbdresultsApp> createState() => _EbdresultsAppState();
}

class _EbdresultsAppState extends State<EbdresultsApp> {
  bool _isOnline = true;
  bool _hasCache = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  // রিস্টার্ট লজিক
  Future<void> _checkInitialStatus() async {
    setState(() => _isChecking = true);
    bool connected = await ConnectivityService.isConnected();
    final prefs = await SharedPreferences.getInstance();
    bool cacheExists = prefs.containsKey('cached_categories');

    setState(() {
      _isOnline = connected;
      _hasCache = cacheExists;
      _isChecking = false;
    });
  }

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
      home: _isChecking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _getHomeWidget(),
    );
  }

  Widget _getHomeWidget() {
    if (!_isOnline && !_hasCache) {
      return Scaffold(
        body: NoInternetWidget(
          onRetry: () {
            _checkInitialStatus();
          },
        ),
      );
    }

    if (widget.isFirstTime && _isOnline) {
      return const SplashScreen();
    }

    return const BottomNav();
  }
}