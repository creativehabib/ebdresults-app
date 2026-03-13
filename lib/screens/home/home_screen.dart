import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
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
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  Future<List<JobModel>> _categoryPostsFuture = Future.value(const []);
  int? _selectedCategoryId;
  String _selectedCategoryName = '';

  @override
  void initState() {
    super.initState();
    _latestPostsFuture = _fetchLatestPosts();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<JobModel>> _fetchLatestPosts() async {
    final posts = await ApiService.fetchList('${ApiUrls.posts}?per_page=20');

    return posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final categories = await ApiService.fetchList(ApiUrls.categories);
    return categories.whereType<Map<String, dynamic>>().where((category) {
      final id = (category['id'] as num?)?.toInt() ?? 0;
      final name = (category['name'] ?? '').toString().trim();
      return id > 0 && name.isNotEmpty;
    }).map((category) {
      return {
        'id': (category['id'] as num).toInt(),
        'name': (category['name'] ?? '').toString(),
      };
    }).toList();
  }

  Future<List<JobModel>> _fetchPostsByCategory(int categoryId) async {
    final posts = await ApiService.fetchPostsByCategory(categoryId, perPage: 20);
    return posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .where((post) => post.title.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static const List<String> _jobKeywords = [
    'jobsnews',
    'jobnews',
    'jobcircular',
    'jobscircular',
    'job',
    'circular',
    'chakri',
    'career',
  ];

  String _normalize(dynamic value) {
    return (value ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  bool _isJobPost(JobModel post) {
    final text = '${_normalize(post.title)} ${_normalize(post.excerpt)}';
    return _jobKeywords.any(text.contains);
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
    if (parsedDate == null) {
      return rawDate;
    }
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  void _openPostDetails(JobModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPostTile(JobModel post) {
    return ListTile(
      dense: true,
      title: Text(_cleanHtml(post.title), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(_formatDate(post.date)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _openPostDetails(post),
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(),
          );
        }

        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('ক্যাটাগরি পাওয়া যায়নি।'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: categories.map((category) {
              final id = category['id'] as int;
              final name = category['name'] as String;
              final isSelected = _selectedCategoryId == id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryId = id;
                      _selectedCategoryName = name;
                      _categoryPostsFuture = _fetchPostsByCategory(id);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCategoryPosts() {
    if (_selectedCategoryId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<JobModel>>(
      future: _categoryPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('এই ক্যাটাগরিতে কোন পোস্ট পাওয়া যায়নি।'),
          );
        }

        return Column(children: posts.map(_buildPostTile).toList());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BD Student Hub'),
      ),
      body: FutureBuilder<List<JobModel>>(
        future: _latestPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Home data load করতে সমস্যা হয়েছে।'));
          }

          final allPosts = snapshot.data ?? [];
          if (allPosts.isEmpty) {
            return const Center(child: Text('Home screen এ এখনো কোন ডাটা পাওয়া যায়নি।'));
          }

          final latestJobs = allPosts.where(_isJobPost).take(5).toList();
          final latestNews = allPosts.where((post) => !_isJobPost(post)).take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              final freshData = await _fetchLatestPosts();
              setState(() {
                _latestPostsFuture = Future.value(freshData);
              });
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _sectionTitle('Categories'),
                _buildCategoriesSection(),
                if (_selectedCategoryId != null) ...[
                  _sectionTitle('$_selectedCategoryName Posts'),
                  _buildSelectedCategoryPosts(),
                ],
                _sectionTitle('Latest Job Circular'),
                if (latestJobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Job circular পাওয়া যায়নি।'),
                  )
                else
                  ...latestJobs.map(_buildPostTile),
                _sectionTitle('Latest News'),
                if (latestNews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('News পাওয়া যায়নি।'),
                  )
                else
                  ...latestNews.map(_buildPostTile),
              ],
            ),
          );
        },
      ),
    );
  }
}
