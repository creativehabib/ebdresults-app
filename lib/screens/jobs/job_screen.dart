import 'dart:convert';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:ebdresults/services/connectivity_service.dart'; // যুক্ত করা হয়েছে
import 'package:ebdresults/widgets/no_internet_widget.dart';   // যুক্ত করা হয়েছে
import 'package:flutter/material.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/widgets/post_card.dart';
import 'package:ebdresults/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<JobModel> _allJobs = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isOffline = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialJobs();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData && _searchQuery.isEmpty && !_isOffline) {
          _loadMoreJobs();
        }
      }
    });
  }

  // ডাটা লোড করার মেইন লজিক
  Future<void> _fetchInitialJobs() async {
    setState(() {
      _isLoadingInitial = true;
      _isOffline = false;
    });

    bool connected = await ConnectivityService.isConnected();

    if (connected) {
      _currentPage = 1;
      _hasMoreData = true;
      _allJobs = [];
      await _loadJobsFromApi(isInitial: true);
    } else {
      await _loadFromCache();
      setState(() {
        _isOffline = true;
        _isLoadingInitial = false;
      });

      if (_allJobs.isNotEmpty) {
        _showOfflineSnackbar();
      }
    }
  }

  // এপিআই থেকে ডাটা আনা
  Future<void> _loadJobsFromApi({bool isInitial = false}) async {
    try {
      final List<JobModel> jobs = await _fetchJobsFromServer(_currentPage);

      if (mounted) {
        setState(() {
          if (isInitial) {
            _allJobs = jobs;
            _saveToCache(jobs); // ক্যাশ সেভ করা
          } else {
            _allJobs.addAll(jobs);
          }

          if (jobs.length < 10) _hasMoreData = false;
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _loadMoreJobs() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadJobsFromApi(isInitial: false);
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

  // ক্যাশিং লজিক
  Future<void> _saveToCache(List<JobModel> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_all_jobs', json.encode(jobs.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_all_jobs');
    if (cachedData != null) {
      final List decoded = json.decode(cachedData);
      _allJobs = decoded.map((e) => JobModel.fromJson(e)).toList();
    }
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("অফলাইন মোড: সংরক্ষিত সার্কুলার দেখানো হচ্ছে"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // সার্চ ফিল্টার লজিক
    final List<JobModel> displayedJobs = _searchQuery.isEmpty
        ? _allJobs
        : _allJobs.where((job) {
      final titleLower = job.title.toLowerCase();
      final categoryLower = job.firstCategoryName.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower) || categoryLower.contains(searchLower);
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            children: const [
              TextSpan(text: 'Latest '),
              TextSpan(text: 'NEWS', style: TextStyle(color: Color(0xffff8f00))),
            ],
          ),
        ),
      ),
      body: _buildBody(theme, isDark, displayedJobs),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark, List<JobModel> displayedJobs) {
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isOffline && _allJobs.isEmpty) {
      return NoInternetWidget(onRetry: _fetchInitialJobs);
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialJobs,
      color: theme.primaryColor,
      child: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text("অফলাইন মোড", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
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
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        decoration: BoxDecoration(
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
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'সার্কুলার বা ক্যাটাগরি খুঁজুন...',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            })
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
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