import 'package:flutter/material.dart';

class AppTheme {
  // ================= কালার প্যালেট =================
  static const Color primaryColor = Color(0xff5c55a5);
  static const Color accentColor = Color(0xffff8f00);

  // Light Mode Colors
  static const Color lightScaffoldBg = Color(0xfff8fafc);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Color(0xff0f172a);

  // Dark Mode Colors
  static const Color darkScaffoldBg = Color(0xff0f172a);
  static const Color darkCardColor = Color(0xff1e293b);
  static const Color darkTextColor = Color(0xfff1f5f9);

  // ================= Light Theme =================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightScaffoldBg,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentColor,
      surface: lightCardColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black12,
      centerTitle: true,
      titleTextStyle: TextStyle(color: lightTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: lightTextColor),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xff475569)),
      bodyMedium: TextStyle(color: Color(0xff64748b)),
    ),

    // সংশোধিত CardThemeData
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // ================= Dark Theme =================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkScaffoldBg,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: accentColor,
      surface: darkCardColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkCardColor,
      surfaceTintColor: darkCardColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: darkTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: darkTextColor),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xffcbd5e1)),
      bodyMedium: TextStyle(color: Color(0xff94a3b8)),
    ),

    cardTheme: CardThemeData(
      color: darkCardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    dividerColor: Colors.white10,
  );
}