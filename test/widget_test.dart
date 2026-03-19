// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ebdresults/core/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebdresults/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // ১. থিম প্রোভাইডার তৈরি করুন
    final themeProvider = ThemeProvider();

    // ২. EbdresultsApp-কে প্রোভাইডার দিয়ে র‍্যাপ করে পাম্প করুন
    // যেহেতু আপনার মেইন অ্যাপে isFirstTime রিকোয়ার্ড, তাই এখানে একটি ভ্যালু পাস করতে হবে।
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => themeProvider,
        child: const EbdresultsApp(isFirstTime: false),
      ),
    );

    // ৩. অ্যাপ লোড হয়েছে কি না তা চেক করুন (উদাহরণস্বরূপ: লোগো বা নির্দিষ্ট টেক্সট)
    // আপনার অ্যাপে যদি 'JOB NEWS' টেক্সটটি থাকে তবে সেটি চেক করবে
    expect(find.textContaining('JOB'), findsWidgets);
  });
}
