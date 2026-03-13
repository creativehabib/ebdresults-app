import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/home/category_post_screen.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
// JobScreen ইমপোর্ট করা হলো
import 'package:ebdresults/screens/jobs/job_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_urls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<JobModel>> _latestPostsFuture;

  // =================== ডায়নামিক ক্যাটাগরির ভেরিয়েবল ===================
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  int _selectedCategoryId = 0; // 0 মানে ডিফল্ট 'Explore'
  // ====================================================================

  int _currentBannerIndex = 0; // স্লাইডারের ডট ট্র্যাক করার জন্য

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // শুরুতে ক্যাটাগরি ফেচ হবে
    _latestPostsFuture = _fetchLatestPosts();
  }

  // =================== API থেকে ক্যাটাগরি ফেচ করার ফাংশন ===================
  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService.fetchList(ApiUrls.categories);

      final List<Map<String, dynamic>> fetchedCategories = [
        {'id': 0, 'name': 'Explore'} // ডিফল্ট ক্যাটাগরি
      ];

      for (var item in response) {
        if (item is Map<String, dynamic>) {
          fetchedCategories.add({
            'id': item['id'],
            'name': _cleanHtml(item['name'] ?? item['title'] ?? 'Unknown'),
          });
        }
      }

      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<List<JobModel>> _fetchLatestPosts() async {
    final posts = await ApiService.fetchList('${ApiUrls.posts}?per_page=20');

    return posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _cleanHtml(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(String rawDate) {
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return rawDate;
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  void _openPostDetails(JobModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)),
    );
  }

  // =================== ডায়নামিক কাস্টম ক্যাটাগরি ট্যাব ===================
  Widget _buildCategoryTabs() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 40,
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category['id'];

          return GestureDetector(
            onTap: () {
              final selectedId = category['id'] as int? ?? 0;

              setState(() {
                _selectedCategoryId = selectedId;
              });

              if (selectedId == 0) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPostScreen(
                    categoryId: selectedId,
                    categoryName: category['name'].toString(),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // নিচের কালারড আন্ডারলাইন
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xff5c55a5), // ছবির পার্পল কালার
                        borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    )
                  else
                    const SizedBox(height: 3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =================== Top Story ব্যানার (স্লাইডার) ===================
  Widget _buildTopStoryCard(JobModel post) {
    return GestureDetector(
      onTap: () => _openPostDetails(post),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
          image: DecorationImage(
            image: NetworkImage(post.imageUrl.isNotEmpty ? post.imageUrl : 'https://via.placeholder.com/400'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // নিচের কালো গ্রেডিয়েন্ট টেক্সট পড়ার সুবিধার জন্য
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _cleanHtml(post.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(post.date),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // "Top Story" ব্যাজ
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff7369b2), // ছবির পার্পল ব্যাজ
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Top Story',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // ফেভারিট আইকন
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== সেকশন হেডার ===================
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            color: const Color(0xff5c55a5), // বাম দিকের পার্পল দাগ
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const Spacer(),
          // View all বাটনে ক্লিক ইভেন্ট দেওয়া হলো
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'view all',
                style: TextStyle(color: Color(0xff5c55a5), fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  // =================== Popular News কার্ড (আপডেট করা হয়েছে) ===================
  Widget _buildNewsCard(JobModel news) {
    return GestureDetector(
      onTap: () => _openPostDetails(news),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // বামদিকের টেক্সট সেকশন
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanHtml(news.title),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                  ),
                  const SizedBox(height: 10),

                  // ================= ডায়নামিক ক্যাটাগরি ব্যাজ =================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff546e7a), // ডার্ক গ্রে/ব্লু ব্যাজ
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news.firstCategoryName, // ডায়নামিক ক্যাটাগরি নাম
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  // ============================================================

                  const SizedBox(height: 12),
                  // তারিখ এবং ভিউ
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_formatDate(news.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),

                      // ================= ডায়নামিক ভিউ =================
                      const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(news.views, style: const TextStyle(fontSize: 12, color: Colors.grey)), // ডায়নামিক ভিউ
                      // ================================================

                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('5', style: TextStyle(fontSize: 12, color: Colors.grey)), // ফেভারিট (আপাতত হার্ডকোড)
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ডানদিকের স্কয়ার ছবি
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 85,
                height: 85,
                child: news.imageUrl.isNotEmpty
                    ? Image.network(
                  news.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                )
                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9), // ব্যাকগ্রাউন্ড কালার

      // ================= মডার্ন অ্যাপবার =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        // ================= এখানে পরিবর্তন করা হয়েছে =================
        elevation: 1, // হালকা শ্যাডোর জন্য 2 দেওয়া হলো
        shadowColor: Colors.grey.withOpacity(0.3), // মডার্ন এবং সফট শ্যাডো কালার
        surfaceTintColor: Colors.white, // স্ক্রল করার সময় যেন কালার পরিবর্তন না হয়
        // ============================================================
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
            children: [
              TextSpan(text: 'JOB '),
              TextSpan(text: 'NEWS', style: TextStyle(color: Color(0xffff8f00))),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      // ===================================================

      body: FutureBuilder<List<JobModel>>(
        future: _latestPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Data load করতে সমস্যা হয়েছে।'));
          }

          final allPosts = snapshot.data ?? [];
          if (allPosts.isEmpty) {
            return const Center(child: Text('কোন ডাটা পাওয়া যায়নি।'));
          }

          final displayedPosts = allPosts;

          // প্রথম ৩টি পোস্টকে ব্যানার/Top Story হিসেবে ধরা হলো
          final topStories = displayedPosts.take(3).toList();
          // বাকিগুলো Popular News
          final popularNews = displayedPosts.skip(3).take(10).toList();

          return RefreshIndicator(
            onRefresh: () async {
              _fetchCategories(); // রিফ্রেশে ক্যাটাগরিও আপডেট হবে
              final freshData = await _fetchLatestPosts();
              setState(() {
                _latestPostsFuture = Future.value(freshData);
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(color: Colors.white, child: _buildCategoryTabs()), // সাদা ব্যাকগ্রাউন্ডে ট্যাব

                  const SizedBox(height: 16),

                  // ক্যাটাগরি সিলেক্ট করার পর যদি কোন ডাটা না থাকে
                  if (displayedPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('এই ক্যাটাগরিতে কোন ডাটা পাওয়া যায়নি।')),
                    )
                  else ...[
                    // ================= Top Story Slider =================
                    if (topStories.isNotEmpty) ...[
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          itemCount: topStories.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildTopStoryCard(topStories[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ডট ইন্ডিকেটর
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          topStories.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index ? const Color(0xff5c55a5) : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // ======================================================

                    const SizedBox(height: 16),

                    // ================= Popular News Section Header =================
                    if (popularNews.isNotEmpty)
                      _buildSectionHeader('Popular News', onViewAll: () {
                        // View all-এ ক্লিক করলে JobScreen-এ যাবে
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JobScreen()),
                        );
                      }),
                    // ===============================================================

                    // Popular News Vertical List
                    if (popularNews.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: popularNews.length,
                        itemBuilder: (context, index) {
                          return _buildNewsCard(popularNews[index]);
                        },
                      ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}