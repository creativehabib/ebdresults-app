import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebdresults/models/notification_model.dart';

class NotificationService {
  static const String _key = 'user_notifications';

  // ১. মেমোরি থেকে সব নোটিফিকেশন সংগ্রহ করা
  static Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);

    if (data == null) return [];

    try {
      final List decoded = json.decode(data);
      return decoded.map((item) => NotificationModel.fromJson(item)).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // নতুনগুলো উপরে থাকবে
    } catch (e) {
      return [];
    }
  }

  // ২. অপঠিত (Unread) নোটিফিকেশনের সংখ্যা বের করা
  static Future<int> getUnreadCount() async {
    final List<NotificationModel> notifications = await getNotifications();
    // যেগুলোর isRead == false সেগুলোকে ফিল্টার করে সংখ্যা রিটার্ন করবে
    return notifications.where((item) => !item.isRead).length;
  }

  // ৩. সব নোটিফিকেশনকে "পঠিত" (Read) হিসেবে মার্ক করা
  static Future<void> markAllAsRead() async {
    final List<NotificationModel> notifications = await getNotifications();
    for (var item in notifications) {
      item.isRead = true;
    }
    await _saveToDisk(notifications);
  }

  // ৪. নতুন নোটিফিকেশন সেভ করা
  static Future<void> addNotification(NotificationModel notification) async {
    final List<NotificationModel> notifications = await getNotifications();

    // ডুপ্লিকেট নোটিফিকেশন এড়াতে আইডি চেক করা
    notifications.removeWhere((item) => item.id == notification.id);

    notifications.add(notification);
    await _saveToDisk(notifications);
  }

  // ৫. নির্দিষ্ট একটি নোটিফিকেশন মুছে ফেলা
  static Future<void> deleteNotification(String id) async {
    final List<NotificationModel> notifications = await getNotifications();
    notifications.removeWhere((item) => item.id == id);

    await _saveToDisk(notifications);
  }

  // ৬. সব নোটিফিকেশন মুছে ফেলা
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ৭. ডাটা মেমোরিতে রাইট করার প্রাইভেট ফাংশন
  static Future<void> _saveToDisk(List<NotificationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}