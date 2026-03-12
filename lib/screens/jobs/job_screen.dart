import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  late Future<List<JobModel>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _fetchJobsNews();
  }

  Future<List<JobModel>> _fetchJobsNews() async {
    final posts = await ApiService.fetchList('${ApiUrls.posts}?per_page=50');
    final categories = await ApiService.fetchList(ApiUrls.categories);
    final tags = await ApiService.fetchList(ApiUrls.tags);

    final jobsCategoryIds = _collectTermIds(categories);
    final jobsTagIds = _collectTermIds(tags);

    final allPosts = posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final filteredPosts = allPosts.where((post) {
      final categoryMatch = post.categoryIds.any(jobsCategoryIds.contains);
      final tagMatch = post.tagIds.any(jobsTagIds.contains);
      final text = '${_normalize(post.title)} ${_normalize(post.excerpt)}';
      final keywordMatch = _jobKeywords.any(text.contains);
      return categoryMatch || tagMatch || keywordMatch;
    }).toList();

    return filteredPosts.isNotEmpty ? filteredPosts : allPosts.take(20).toList();
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

  Set<int> _collectTermIds(List<dynamic> terms) {
    return terms.whereType<Map<String, dynamic>>().where((term) {
      final slug = _normalize(term['slug']);
      final name = _normalize(term['name']);
      return _jobKeywords.any((key) => slug.contains(key) || name.contains(key));
    }).map((term) => (term['id'] as num?)?.toInt() ?? 0).where((id) => id > 0).toSet();
  }

  String _normalize(dynamic value) {
    return (value ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Job Circular'),
      ),
      body: FutureBuilder<List<JobModel>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Latest job circular load করতে সমস্যা হয়েছে।'),
            );
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(
              child: Text('Latest job circular পাওয়া যায়নি।'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final freshData = await _fetchJobsNews();
              setState(() {
                _jobsFuture = Future.value(freshData);
              });
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return ListTile(
                  title: Text(_cleanHtml(job.title)),
                  subtitle: Text(
                    '${_formatDate(job.date)}\n${_cleanHtml(job.excerpt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openPost(job.link),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
