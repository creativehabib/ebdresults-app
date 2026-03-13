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
  final ScrollController _scrollController = ScrollController();

  // ================= সার্চের জন্য নতুন কন্ট্রোলার ও ভেরিয়েবল =================
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // =========================================================================

  List<JobModel> _allJobs = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialJobs();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData) {
          _loadMoreJobs();
        }
      }
    });
  }

  Future<void> _fetchInitialJobs() async {
    setState(() {
      _isLoadingInitial = true;
      _currentPage = 1;
      _allJobs = [];
      _hasMoreData = true;
    });

    try {
      final List<JobModel> jobs = await _fetchJobsFromServer(1);
      setState(() {
        _allJobs = jobs;
        _isLoadingInitial = false;
        if (jobs.length < 10) _hasMoreData = false;
      });
    } catch (e) {
      setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _loadMoreJobs() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final List<JobModel> newJobs = await _fetchJobsFromServer(_currentPage);

      if (newJobs.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _allJobs.addAll(newJobs);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<List<JobModel>> _fetchJobsFromServer(int page) async {
    final String url = '${ApiUrls.posts}?page=$page&per_page=10&orderby=date&order=desc';
    final List<dynamic> response = await ApiService.fetchList(url);

    return response
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .where((post) => post.title.trim().isNotEmpty)
        .toList();
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

  void _openJobDetails(JobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(post: job)),
    );
  }

  // =================== মডার্ন সার্চ বার উইজেট ===================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value; // সার্চ কুয়েরি আপডেট হবে
            });
          },
          decoration: InputDecoration(
            hintText: 'সার্কুলার বা ক্যাটাগরি খুঁজুন...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
            // টেক্সট থাকলে মুছার (Clear) বাটন দেখাবে
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                // কীবোর্ড নামিয়ে দেওয়ার জন্য
                FocusScope.of(context).unfocus();
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
  // ==============================================================

  Widget _buildListCard(JobModel job) {
    return GestureDetector(
      onTap: () => _openJobDetails(job),
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
                    _cleanHtml(job.title),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff546e7a),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.firstCategoryName.isNotEmpty ? job.firstCategoryName : 'Job Circular',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_formatDate(job.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(job.views, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('5', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                child: job.imageUrl.isNotEmpty
                    ? Image.network(
                  job.imageUrl,
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
    // ================= ফিল্টারিং লজিক =================
    // সার্চ বারে কিছু লিখলে টাইটেল বা ক্যাটাগরির সাথে মিলিয়ে জব ফিল্টার হবে
    final List<JobModel> displayedJobs = _searchQuery.isEmpty
        ? _allJobs
        : _allJobs.where((job) {
      final titleLower = job.title.toLowerCase();
      final categoryLower = job.firstCategoryName.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower) || categoryLower.contains(searchLower);
    }).toList();
    // ==================================================

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text('Latest Job Circular', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
          await _fetchInitialJobs();
        },
        child: _isLoadingInitial
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // সার্চ বার কল করা হলো
            _buildSearchBar(),

            Expanded(
              child: displayedJobs.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'কোন ফলাফল পাওয়া যায়নি!'
                      : 'কোন তথ্য পাওয়া যায়নি',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: displayedJobs.length,
                itemBuilder: (context, index) => _buildListCard(displayedJobs[index]),
              ),
            ),

            // সার্চ করা অবস্থায় আর লোড হবে না, শুধু মেইন লিস্টে থাকলে লোড হবে
            if (_isLoadingMore && _searchQuery.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}