import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_urls.dart';

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
    final posts = await _fetchPostsFromSources();
    final categories = await ApiService.fetchList(ApiUrls.categories);
    final tags = await ApiService.fetchList(ApiUrls.tags);

    final jobsCategoryIds = _collectTermIds(categories);
    final jobsTagIds = _collectTermIds(tags);

    final allPosts = posts
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .where((post) => post.title.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (allPosts.isEmpty) {
      return [];
    }

    final filteredPosts = allPosts.where((post) {
      final categoryMatch = post.categoryIds.any(jobsCategoryIds.contains);
      final tagMatch = post.tagIds.any(jobsTagIds.contains);
      final text =
          '${_normalize(post.title)} ${_normalize(post.excerpt)} ${_normalize(post.content)}';
      final keywordMatch = _jobKeywords.any(text.contains);
      return categoryMatch || tagMatch || keywordMatch;
    }).toList();

    return filteredPosts.isNotEmpty ? filteredPosts : allPosts.take(30).toList();
  }

  Future<List<dynamic>> _fetchPostsFromSources() async {
    final pageOne = await ApiService.fetchList('${ApiUrls.posts}?page=1');
    final pageTwo = await ApiService.fetchList('${ApiUrls.posts}?page=2');
    final legacyJobs = await ApiService.fetchList(ApiUrls.legacyJobs);
    final legacyNews = await ApiService.fetchList(ApiUrls.legacyNews);

    final merged = <dynamic>[]
      ..addAll(pageOne)
      ..addAll(pageTwo)
      ..addAll(legacyJobs)
      ..addAll(legacyNews);

    final uniqueByKey = <String, dynamic>{};
    for (final item in merged.whereType<Map<String, dynamic>>()) {
      final id = item['id']?.toString();
      final slug = item['slug']?.toString() ?? '';
      final link = item['link']?.toString() ?? item['url']?.toString() ?? '';
      final key = (id != null && id.isNotEmpty)
          ? 'id:$id'
          : (slug.isNotEmpty
                ? 'slug:$slug'
                : (link.isNotEmpty
                      ? 'link:$link'
                      : 'title:${item['title'] ?? item['name'] ?? ''}'));
      uniqueByKey[key] = item;
    }

    return uniqueByKey.values.toList();
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
    'recruitment',
    'govtjobs',
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

  void _openJobDetails(JobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(post: job)),
    );
  }

  Widget _buildGridCard(JobModel job) {
    final previewText = _cleanHtml(job.excerpt.isNotEmpty ? job.excerpt : job.content);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openJobDetails(job),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: job.imageUrl.isNotEmpty
                    ? Image.network(
                        job.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, size: 32),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                _cleanHtml(job.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _formatDate(job.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Text(
                previewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800, height: 1.3, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(JobModel job) {
    final previewText = _cleanHtml(job.excerpt.isNotEmpty ? job.excerpt : job.content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openPost(job.link),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.imageUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.network(
                  job.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                _cleanHtml(job.title),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _formatDate(job.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                previewText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800, height: 1.4),
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
              child: Text('Job Circular পাওয়া যায়নি। Pull down করে refresh দিন।'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final freshData = await _fetchJobsNews();
              setState(() {
                _jobsFuture = Future.value(freshData);
              });
            },
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: jobs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) => _buildGridCard(jobs[index]),
            ),
          );
        },
      ),
    );
  }
}
