import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/widgets/post_card.dart';
import 'package:ebdresults/widgets/app_drawer.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        if (!_isLoadingMore && _hasMoreData && _searchQuery.isEmpty) {
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
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _isLoadingInitial = false;
          if (jobs.length < 10) _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _loadMoreJobs() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final List<JobModel> newJobs = await _fetchJobsFromServer(_currentPage);

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
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

  // সার্চ বার থিম অনুযায়ী আপডেট করা হয়েছে
  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          // থিমের কার্ড কালার ব্যবহার করা হয়েছে
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'সার্কুলার বা ক্যাটাগরি খুঁজুন...',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: isDark ? Colors.white38 : Colors.grey, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<JobModel> displayedJobs = _searchQuery.isEmpty
        ? _allJobs
        : _allJobs.where((job) {
      final titleLower = job.title.toLowerCase();
      final categoryLower = job.firstCategoryName.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower) || categoryLower.contains(searchLower);
    }).toList();

    return Scaffold(
      // backgroundColor এখন অটোমেটিক থিম থেকে নেবে
      drawer: const AppDrawer(),

      appBar: AppBar(
        // অ্যাপবার থিম অনুযায়ী অটো অ্যাডজাস্ট হবে
        title: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87
            ),
            children: const [
              TextSpan(text: 'Latest '),
              TextSpan(text: 'NEWS', style: TextStyle(color: Color(0xffff8f00))),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
          await _fetchInitialJobs();
        },
        color: theme.primaryColor,
        child: _isLoadingInitial
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: displayedJobs.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isNotEmpty ? 'কোন ফলাফল পাওয়া যায়নি!' : 'কোন তথ্য পাওয়া যায়নি',
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 16),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: displayedJobs.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    post: displayedJobs[index],
                    fallbackCategoryName: 'Job Circular',
                  );
                },
              ),
            ),
            if (_isLoadingMore && _searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: theme.primaryColor),
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