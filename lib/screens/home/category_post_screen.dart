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
  // =================== Pagination-এর জন্য প্রয়োজনীয় ভেরিয়েবল ===================
  final ScrollController _scrollController = ScrollController();
  List<JobModel> _posts = [];

  bool _isLoadingInitial = true; // প্রথমবার লোড হওয়ার জন্য
  bool _isLoadingMore = false; // নিচে স্ক্রল করে আরও ডাটা আনার জন্য
  int _currentPage = 1;
  bool _hasMoreData = true; // আর ডাটা আছে কিনা তা ট্র্যাক করার জন্য
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts();

    // স্ক্রল লিসেনার সেট করা হলো
    _scrollController.addListener(() {
      // যদি ইউজার স্ক্রল করে একদম নিচে চলে আসে (200 পিক্সেল আগে থেকেই লোড শুরু হবে)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData) {
          _loadMorePosts();
        }
      }
    });
  }

  // প্রথমবার বা রিফ্রেশ করলে ডাটা আনার ফাংশন
  Future<void> _fetchInitialPosts() async {
    setState(() {
      _isLoadingInitial = true;
      _currentPage = 1;
      _posts = [];
      _hasMoreData = true;
    });

    try {
      final List<JobModel> fetchedPosts = await _fetchPostsFromApi(1);

      if (mounted) {
        setState(() {
          _posts = fetchedPosts;
          _isLoadingInitial = false;
          // যদি ২০ টার কম ডাটা আসে, তারমানে আর ডাটা নেই
          if (fetchedPosts.length < 20) _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  // নিচে স্ক্রল করলে পরবর্তী পেজের ডাটা আনার ফাংশন
  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final List<JobModel> newPosts = await _fetchPostsFromApi(_currentPage);

      if (mounted) {
        setState(() {
          if (newPosts.isEmpty) {
            _hasMoreData = false; // আর কোনো ডাটা নেই
          } else {
            _posts.addAll(newPosts); // পুরনো লিস্টের সাথে নতুন ডাটা যোগ হলো
            if (newPosts.length < 20) _hasMoreData = false;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  // API থেকে ডাটা ফেচ করার মূল ফাংশন
  Future<List<JobModel>> _fetchPostsFromApi(int page) async {
    final response = await ApiService.fetchList(
      // এখানে page প্যারামিটারটি পাস করা হলো
      ApiUrls.postsByCategoryQuery(widget.categoryId, perPage: 20, page: page),
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _scrollController.dispose(); // মেমোরি লিক রোধ করার জন্য ডিসপোজ
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _fetchInitialPosts, // রিফ্রেশ করলে আবার প্রথম থেকে ডাটা আসবে
        child: _isLoadingInitial
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
            ? SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: const Text('এই ক্যাটাগরিতে কোন পোস্ট পাওয়া যায়নি।'),
          ),
        )
            : ListView.builder(
          controller: _scrollController, // স্ক্রল কন্ট্রোলার যুক্ত করা হলো
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          // আইটেম কাউন্ট ১ বেশি দেওয়া হয়েছে যাতে নিচে লোডিং ইন্ডিকেটর দেখানো যায়
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // যদি লিস্টের একদম শেষ আইটেম হয় এবং লোডিং চলতে থাকে
            if (index == _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildListCard(_posts[index]);
          },
        ),
      ),
    );
  }
}