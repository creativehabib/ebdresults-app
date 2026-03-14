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
              ).then((_) {
                setState(() {
                  _selectedCategoryId = 0;
                });
              });
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
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xff5c55a5),
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

  // ================= Top Story Card  =================
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
            Positioned(
              bottom: 0, left: 0, right: 0,
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
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
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
            ),
            Positioned(
              top: 16, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xff7369b2), borderRadius: BorderRadius.circular(4)),
                child: const Text('Top Story', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
          Container(width: 3, height: 18, color: const Color(0xff5c55a5)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
          const Spacer(),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('view all', style: TextStyle(color: Color(0xff5c55a5), fontWeight: FontWeight.w500, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),

      drawer: const AppDrawer(),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.3),
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
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
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87), onPressed: () {}),
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
                  Container(color: Colors.white, child: _buildCategoryTabs()),

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
                            color: _currentBannerIndex == index ? const Color(0xff5c55a5) : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

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

                        // ================= PostCard =================
                        return PostCard(
                          post: popularNews[index],
                          fallbackCategoryName: 'Popular News',
                        );
                        // =========================================================================

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