import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/home/category_post_screen.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/screens/jobs/job_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/widgets/app_drawer.dart';
import 'package:ebdresults/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<List<JobModel>>> _homeDataFuture;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  int _selectedCategoryId = 0;

  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _homeDataFuture = _fetchHomeData();
  }

  Future<List<List<JobModel>>> _fetchHomeData() async {
    try {
      final topStoriesResponse = ApiService.fetchList('${ApiUrls.base}/posts/last-modify-posts');
      final popularNewsResponse = ApiService.fetchList('${ApiUrls.base}/posts/most-popular');

      final results = await Future.wait([topStoriesResponse, popularNewsResponse]);

      final topStories = results[0]
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .take(3)
          .toList();

      final popularNews = results[1]
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();

      return [topStories, popularNews];
    } catch (e) {
      return [[], []];
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService.fetchList(ApiUrls.categories);

      final List<Map<String, dynamic>> fetchedCategories = [
        {'id': 0, 'name': 'Explore'}
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

  // ================= থিম অনুযায়ী আপডেট করা ক্যাটাগরি ট্যাব =================
  Widget _buildCategoryTabs() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 40,
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_categories.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor, // থিম অনুযায়ী ব্যাকগ্রাউন্ড
      height: 45,
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
              ).then((_) {
                setState(() {
                  _selectedCategoryId = 0;
                });
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
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

  Widget _buildTopStoryCard(JobModel post) {
    return GestureDetector(
      onTap: () => _openPostDetails(post),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // রেডিয়াস বাড়ানো হয়েছে
          image: DecorationImage(
            image: NetworkImage(post.imageUrl.isNotEmpty ? post.imageUrl : 'https://via.placeholder.com/400'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _cleanHtml(post.title),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(_formatDate(post.date), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4)
                ),
                child: const Text('Top Story', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text('view all', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
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
          IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {}),
        ],
      ),

      body: FutureBuilder<List<List<JobModel>>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Data load করতে সমস্যা হয়েছে।'));
          }

          final topStories = snapshot.data?[0] ?? [];
          final popularNews = snapshot.data?[1] ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              _fetchCategories();
              setState(() {
                _homeDataFuture = _fetchHomeData();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTabs(),

                  const SizedBox(height: 16),

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
                            color: _currentBannerIndex == index ? Theme.of(context).primaryColor : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (popularNews.isNotEmpty) ...[
                    _buildSectionHeader('Popular News', onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JobScreen()),
                      );
                    }),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: popularNews.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: popularNews[index],
                          fallbackCategoryName: 'Popular News',
                        );
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