import 'dart:convert';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:ebdresults/services/connectivity_service.dart';
import 'package:ebdresults/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/category_post_screen.dart';

class JobCategoriesScreen extends StatefulWidget {
  const JobCategoriesScreen({super.key});

  @override
  State<JobCategoriesScreen> createState() => _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends State<JobCategoriesScreen> {
  // ১. প্রয়োজনীয় ভেরিয়েবল
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;       // প্রথমবার লোডের জন্য
  bool _isLoadMore = false;     // স্ক্রল করে নিচে নামলে লোডের জন্য
  int _currentPage = 1;         // বর্তমান পেজ নম্বর
  bool _hasMoreData = true;     // সার্ভারে আরও ডাটা আছে কি না
  bool _isOffline = false;      // অফলাইন মোড কি না

  @override
  void initState() {
    super.initState();
    _fetchInitialData();

    // ২. স্ক্রল লিসেনার: ৯০% নিচে গেলেই নতুন ডাটা লোড হবে
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoadMore && _hasMoreData && !_isOffline) {
          _loadMoreCategories();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ৩. ডাটা লোড করার মেইন ফাংশন
  Future<void> _fetchInitialData() async {
    bool connected = await ConnectivityService.isConnected();

    if (connected) {
      setState(() {
        _isOffline = false;
        // যদি লিস্ট একদম খালি থাকে তবেই বড় লোডার দেখাবে
        _isLoading = _categories.isEmpty;
      });

      _currentPage = 1;
      await _fetchDataFromApi(isRefresh: true);
    } else {
      // ইন্টারনেট না থাকলে যদি লিস্ট খালি থাকে তবে ক্যাশ থেকে আনবে
      if (_categories.isEmpty) {
        await _loadFromCache();
      }

      setState(() {
        _isOffline = true;
        _isLoading = false;
      });

      // ডাটা থাকার পরও অফলাইনে রিফ্রেশ করলে সতর্কবার্তা দেবে
      if (_categories.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ইন্টারনেট সংযোগ নেই! সংরক্ষিত ডাটা দেখানো হচ্ছে।"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ৪. এপিআই থেকে ডাটা ফেচ করা
  Future<void> _fetchDataFromApi({bool isRefresh = false}) async {
    try {
      final String connector = ApiUrls.categories.contains('?') ? '&' : '?';
      // আপনার এপিআই অনুযায়ী ২০টি করে ডাটা পেজিনেশন
      final String url = "${ApiUrls.categories}${connector}page=$_currentPage&per_page=20";

      final response = await ApiService.fetchList(url);

      if (response.isEmpty) {
        _hasMoreData = false;
      } else {
        final List<Map<String, dynamic>> fetchedItems = response.map((item) {
          return {
            'id': item['id'],
            'name': _cleanHtml(item['name'] ?? 'Unknown'),
            'count': int.tryParse((item['posts_count'] ?? item['count'] ?? 0).toString()) ?? 0,
          };
        }).toList();

        if (isRefresh) {
          _categories = fetchedItems; // নতুন ডাটা দিয়ে পুরাতন ডাটা রিপ্লেস
        } else {
          _categories.addAll(fetchedItems);
        }

        // ২০টির কম আসলে বুঝবো আর ডাটা নেই
        if (fetchedItems.length < 20) _hasMoreData = false;

        // প্রথম পেজের ডাটা লোকাল স্টোরেজে সেভ (Caching)
        if (_currentPage == 1) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_categories', json.encode(_categories));
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
      _hasMoreData = false;
    }
  }

  // ৫. ক্যাশ (SharedPrefs) থেকে ডাটা লোড
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    String? cached = prefs.getString('cached_categories');
    if (cached != null) {
      _categories = List<Map<String, dynamic>>.from(json.decode(cached));
    }
  }

  // ৬. নিচে স্ক্রল করলে লোড মোর
  Future<void> _loadMoreCategories() async {
    setState(() => _isLoadMore = true);
    _currentPage++;
    await _fetchDataFromApi();
    setState(() => _isLoadMore = false);
  }

  String _cleanHtml(String rawText) => rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Categories'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // লোডিং হচ্ছে এবং আগে থেকে কোনো ডাটা নেই
    if (_isLoading && _categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ইন্টারনেট নেই এবং সেভ করা কোনো ডাটাও নেই
    if (_isOffline && _categories.isEmpty) {
      return NoInternetWidget(onRetry: _fetchInitialData);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      child: Column(
        children: [
          // অফলাইন নোটিশ বার
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                "অফলাইন মোড: সংরক্ষিত ডাটা দেখানো হচ্ছে",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category, theme, isDark);
              },
            ),
          ),

          // লোড মোর এর ছোট ইন্ডিকেটর
          if (_isLoadMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () async {
        if (await ConnectivityService.isConnected()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryPostScreen(
                categoryId: category['id'],
                categoryName: category['name'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ক্যাটাগরি ওপেন করতে ইন্টারনেট সংযোগ লাগবে!")),
          );
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5)
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline_rounded, color: theme.primaryColor, size: 28),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category['name'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${category['count']} টি চাকরি",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}