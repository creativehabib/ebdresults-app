import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/api_urls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<JobModel>> _latestPostsFuture;

  @override
  void initState() {
    super.initState();
    _latestPostsFuture = _fetchLatestPosts();
  }

  Future<List<JobModel>> _fetchLatestPosts() async {
    final posts = await ApiService.fetchList('${ApiUrls.posts}?per_page=20');

    return posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
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

  Future<void> _openPost(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _openPost(post.link),
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
