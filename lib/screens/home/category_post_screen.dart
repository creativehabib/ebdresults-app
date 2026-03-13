import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryPostScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostScreen> createState() => _CategoryPostScreenState();
}

class _CategoryPostScreenState extends State<CategoryPostScreen> {
  late Future<List<JobModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchCategoryPosts();
  }

  Future<List<JobModel>> _fetchCategoryPosts() async {
    final response = await ApiService.fetchList(
      ApiUrls.postsByCategoryQuery(widget.categoryId),
    );

    return response
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
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  void _openPostDetails(JobModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(post: post)),
    );
  }

  Widget _buildListCard(JobModel post) {
    return GestureDetector(
      onTap: () => _openPostDetails(post),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanHtml(post.title),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff546e7a),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.firstCategoryName.isNotEmpty
                          ? post.firstCategoryName
                          : widget.categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.date),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 85,
                height: 85,
                child: post.imageUrl.isNotEmpty
                    ? Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade200),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
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
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        surfaceTintColor: Colors.white,
      ),
      body: FutureBuilder<List<JobModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('ডাটা লোড করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Text('এই ক্যাটাগরিতে কোন পোস্ট পাওয়া যায়নি।'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final freshData = await _fetchCategoryPosts();
              if (!mounted) return;
              setState(() {
                _postsFuture = Future.value(freshData);
              });
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) => _buildListCard(posts[index]),
            ),
          );
        },
      ),
    );
  }
}
