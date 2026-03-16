import 'dart:convert';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/home/category_post_screen.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/screens/jobs/job_screen.dart';
import 'package:ebdresults/screens/notification_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:ebdresults/services/connectivity_service.dart';
import 'package:ebdresults/services/notification_service.dart'; // যুক্ত করা হয়েছে
import 'package:ebdresults/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/widgets/app_drawer.dart';
import 'package:ebdresults/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JobModel> _topStories = [];
  List<JobModel> _popularNews = [];
  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = true;
  bool _isOffline = false;
  int _currentBannerIndex = 0;
  int _selectedCategoryId = 0;
  int _unreadNotifications = 0; // আনরিড নোটিফিকেশন কাউন্ট

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _updateUnreadCount(); // অ্যাপ ওপেন হলে কাউন্ট চেক করবে
  }

  // আনরিড নোটিফিকেশন সংখ্যা আপডেট করার ফাংশন
  Future<void> _updateUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotifications = count;
      });
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    bool connected = await ConnectivityService.isConnected();

    if (connected) {
      _isOffline = false;
      await Future.wait([
        _fetchCategories(),
        _fetchHomeData(),
      ]);
    } else {
      await _loadFromCache();
      setState(() {
        _isOffline = true;
      });

      if (_topStories.isNotEmpty || _popularNews.isNotEmpty) {
        _showOfflineSnackbar();
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchHomeData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchList('${ApiUrls.base}/posts/last-modify-posts'),
        ApiService.fetchList('${ApiUrls.base}/posts/most-popular'),
      ]);

      _topStories = results[0]
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .take(3)
          .toList();

      _popularNews = results[1]
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_top_stories', json.encode(_topStories.map((e) => e.toJson()).toList()));
      await prefs.setString('cached_popular_news', json.encode(_popularNews.map((e) => e.toJson()).toList()));

    } catch (e) {
      debugPrint("Home Data Error: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService.fetchList(ApiUrls.categories);
      final List<Map<String, dynamic>> fetchedCategories = [{'id': 0, 'name': 'Explore'}];

      for (var item in response) {
        if (item is Map<String, dynamic>) {
          fetchedCategories.add({
            'id': item['id'],
            'name': _cleanHtml(item['name'] ?? 'Unknown'),
          });
        }
      }
      _categories = fetchedCategories;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_home_categories', json.encode(_categories));
    } catch (e) {
      debugPrint("Category Error: $e");
    }
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    String? topJson = prefs.getString('cached_top_stories');
    String? popularJson = prefs.getString('cached_popular_news');
    String? catJson = prefs.getString('cached_home_categories');

    if (topJson != null) {
      _topStories = (json.decode(topJson) as List).map((e) => JobModel.fromJson(e)).toList();
    }
    if (popularJson != null) {
      _popularNews = (json.decode(popularJson) as List).map((e) => JobModel.fromJson(e)).toList();
    }
    if (catJson != null) {
      _categories = List<Map<String, dynamic>>.from(json.decode(catJson));
    }
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("আপনি অফলাইনে আছেন। পুরাতন ডাটা দেখানো হচ্ছে।"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _cleanHtml(String rawText) {
    return rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String _formatDate(String rawDate) {
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return rawDate;
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            children: const [
              TextSpan(text: 'JOB '),
              TextSpan(text: 'NEWS', style: TextStyle(color: Color(0xffff8f00))),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),

          // --- নোটিফিকেশন আইকন উইথ ব্যাজ এবং নেভিগেশন ---
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  ).then((_) {
                    // নোটিফিকেশন স্ক্রিন থেকে ফিরে আসলে কাউন্ট আপডেট হবে
                    _updateUnreadCount();
                  });
                },
              ),
              // যদি অপঠিত নোটিফিকেশন থাকে তবেই লাল ব্যাজ দেখাবে
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isOffline && _topStories.isEmpty && _popularNews.isEmpty) {
      return NoInternetWidget(onRetry: _loadInitialData);
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text("অফলাইন মোড", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11)),
              ),

            _buildCategoryTabs(),
            const SizedBox(height: 16),

            if (_topStories.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: _topStories.length,
                  onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                  itemBuilder: (context, index) => _buildTopStoryCard(_topStories[index]),
                ),
              ),
              const SizedBox(height: 12),
              _buildBannerDots(),
            ],

            if (_popularNews.isNotEmpty) ...[
              _buildSectionHeader('Popular News', onViewAll: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const JobScreen()));
              }),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _popularNews.length,
                itemBuilder: (context, index) => PostCard(
                  post: _popularNews[index],
                  fallbackCategoryName: 'Popular News',
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category['id'];

          return GestureDetector(
            onTap: () {
              if (_isOffline) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("অফলাইনে ক্যাটাগরি দেখা সম্ভব নয়")));
                return;
              }
              int selectedId = category['id'] as int;
              if (selectedId == 0) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPostScreen(categoryId: selectedId, categoryName: category['name'])));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category['name'], style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.white70 : Colors.black54))),
                  if (isSelected) Container(height: 3, width: 20, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(2))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStoryCard(JobModel post) {
    return GestureDetector(
      onTap: () {
        if (_isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("বিস্তারিত দেখতে ইন্টারনেট লাগবে")));
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(post.imageUrl.isNotEmpty ? post.imageUrl : 'https://via.placeholder.com/400'), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.85), Colors.transparent]))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(_cleanHtml(post.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.access_time, color: Colors.white70, size: 14), const SizedBox(width: 4), Text(_formatDate(post.date), style: const TextStyle(color: Colors.white70, fontSize: 12))]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_topStories.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentBannerIndex == index ? 20 : 6, height: 6, decoration: BoxDecoration(color: _currentBannerIndex == index ? Theme.of(context).primaryColor : Colors.grey.shade400, borderRadius: BorderRadius.circular(4)))),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(width: 4, height: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (onViewAll != null) TextButton(onPressed: onViewAll, child: Text('view all', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}