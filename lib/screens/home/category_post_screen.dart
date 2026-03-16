import 'dart:convert';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:ebdresults/services/connectivity_service.dart';
import 'package:ebdresults/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:ebdresults/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ScrollController _scrollController = ScrollController();
  List<JobModel> _posts = [];

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData && !_isOffline) {
          _loadMorePosts();
        }
      }
    });
  }

  // ডাটা লোড করার মেইন লজিক
  Future<void> _fetchInitialPosts() async {
    setState(() {
      _isLoadingInitial = true;
      _isOffline = false;
    });

    bool connected = await ConnectivityService.isConnected();

    if (connected) {
      _currentPage = 1;
      _hasMoreData = true;
      await _loadFromApi(isInitial: true);
    } else {
      await _loadFromCache();
      setState(() {
        _isOffline = true;
        _isLoadingInitial = false;
      });

      if (_posts.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("অফলাইন মোড: ক্যাশ ডাটা দেখানো হচ্ছে"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // এপিআই থেকে ডাটা আনা
  Future<void> _loadFromApi({bool isInitial = false}) async {
    try {
      final List<JobModel> fetchedPosts = await _fetchPostsFromApi(_currentPage);

      if (mounted) {
        setState(() {
          if (isInitial) {
            _posts = fetchedPosts;
            _saveToCache(fetchedPosts); // ক্যাশ সেভ করা
          } else {
            _posts.addAll(fetchedPosts);
          }

          if (fetchedPosts.length < 20) _hasMoreData = false;
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _loadFromApi(isInitial: false);
  }

  Future<List<JobModel>> _fetchPostsFromApi(int page) async {
    final response = await ApiService.fetchList(
      ApiUrls.postsByCategoryQuery(widget.categoryId, perPage: 20, page: page),
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ক্যাশিং লজিক
  Future<void> _saveToCache(List<JobModel> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'cached_posts_cat_${widget.categoryId}';
    await prefs.setString(key, json.encode(posts.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'cached_posts_cat_${widget.categoryId}';
    String? cachedData = prefs.getString(key);

    if (cachedData != null) {
      final List decoded = json.decode(cachedData);
      _posts = decoded.map((e) => JobModel.fromJson(e)).toList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        elevation: isDark ? 0 : 1,
      ),
      body: _buildBody(theme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    // ইন্টারনেট নেই এবং ক্যাশ ডাটাও নেই
    if (_isOffline && _posts.isEmpty) {
      return NoInternetWidget(onRetry: _fetchInitialPosts);
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialPosts,
      color: theme.primaryColor,
      child: _posts.isEmpty
          ? _buildEmptyState(isDark)
          : _buildListView(theme),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Text(
          'এই ক্যাটাগরিতে কোন পোস্ট পাওয়া যায়নি।',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildListView(ThemeData theme) {
    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            color: Colors.orange.shade800,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Text(
              "অফলাইন মোড",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _posts.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: theme.primaryColor),
                  ),
                );
              }

              return PostCard(
                post: _posts[index],
                fallbackCategoryName: widget.categoryName,
              );
            },
          ),
        ),
      ],
    );
  }
}