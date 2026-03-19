import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebdresults/models/notification_model.dart';
import 'package:ebdresults/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // ডাটা লোড এবং পঠিত হিসেবে মার্ক করার প্রাথমিক ফাংশন
  Future<void> _initData() async {
    await _loadNotifications();
    await _markAsRead();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = await NotificationService.getNotifications();

    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  // স্ক্রিনে ঢোকা মাত্রই সবগুলোকে পঠিত হিসেবে মার্ক করা
  Future<void> _markAsRead() async {
    await NotificationService.markAllAsRead();
  }

  Future<void> _handleNotificationTap(NotificationModel item) async {
    if (item.postId == null || item.postId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই বিজ্ঞপ্তির জন্য কোনো বিস্তারিত তথ্য পাওয়া যায়নি।')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.fetchSingle('posts/${item.postId}');

      if (mounted) Navigator.pop(context);

      if (response != null) {
        final job = JobModel.fromJson(response);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailsScreen(post: job)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('পোস্টটি সার্ভারে খুঁজে পাওয়া যায়নি।')),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Notification Redirection Error: $e");
    }
  }

  void _deleteNotification(int index) async {
    final String id = _notifications[index].id;
    await NotificationService.deleteNotification(id);

    setState(() {
      _notifications.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মুছে ফেলা হয়েছে'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _clearAll() async {
    await NotificationService.clearAll();
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () {
                _showDeleteAllDialog();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _initData,
        child: _notifications.isEmpty
            ? _buildEmptyState(isDark)
            : ListView.builder(
          itemCount: _notifications.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.redAccent,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (direction) => _deleteNotification(index),
              child: _buildNotificationItem(notification, theme, isDark),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('সব মুছে ফেলুন?'),
        content: const Text('আপনি কি নিশ্চিত যে সব নোটিফিকেশন মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          TextButton(
            onPressed: () {
              _clearAll();
              Navigator.pop(context);
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(Icons.notifications_active_outlined, color: theme.primaryColor, size: 20),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              item.message,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('hh:mm a | dd MMM yyyy').format(item.dateTime),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(item),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 80, color: isDark ? Colors.white10 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'কোনো নোটিফিকেশন নেই',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('নতুন চাকরির আপডেট আসলে এখানে দেখতে পাবেন', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}