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
    final posts = await ApiService.fetchList(ApiUrls.posts);
    final categories = await ApiService.fetchList(ApiUrls.categories);
    final tags = await ApiService.fetchList(ApiUrls.tags);

    final jobsNewsCategoryIds = _collectTermIds(categories, 'jobs_news');
    final jobsNewsTagIds = _collectTermIds(tags, 'jobs_news');

    final allPosts = posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList();

    return allPosts.where((post) {
      final categoryMatch = post.categoryIds.any(jobsNewsCategoryIds.contains);
      final tagMatch = post.tagIds.any(jobsNewsTagIds.contains);
      final keywordMatch =
          _normalize(post.title).contains('jobs_news') ||
          _normalize(post.title).contains('job') ||
          _normalize(post.excerpt).contains('jobs_news');
      return categoryMatch || tagMatch || keywordMatch;
    }).toList();
  }

  Set<int> _collectTermIds(List<dynamic> terms, String keyword) {
    return terms.whereType<Map<String, dynamic>>().where((term) {
      final slug = _normalize(term['slug']);
      final name = _normalize(term['name']);
      return slug.contains(_normalize(keyword)) || name.contains(_normalize(keyword));
    }).map((term) => (term['id'] as num?)?.toInt() ?? 0).where((id) => id > 0).toSet();
  }

  String _normalize(dynamic value) {
    return (value ?? '').toString().toLowerCase().replaceAll(' ', '_');
  }

  String _cleanHtml(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
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
        title: const Text('Jobs News'),
      ),
      body: FutureBuilder<List<JobModel>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Jobs news load করতে সমস্যা হয়েছে।'),
            );
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(
              child: Text('Jobs News পাওয়া যায়নি।'),
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
