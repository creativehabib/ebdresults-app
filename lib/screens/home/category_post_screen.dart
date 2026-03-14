import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:ebdresults/widgets/post_card.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreData) {
          _loadMorePosts();
        }
      }
    });
  }

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
          if (fetchedPosts.length < 20) _hasMoreData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final List<JobModel> newPosts = await _fetchPostsFromApi(_currentPage);

      if (mounted) {
        setState(() {
          if (newPosts.isEmpty) {
            _hasMoreData = false;
          } else {
            _posts.addAll(newPosts);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialPosts,
        color: Colors.black87,
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
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // =================  PostCard  =================
            return PostCard(
              post: _posts[index],
              fallbackCategoryName: widget.categoryName,
            );
            // =========================================================================

          },
        ),
      ),
    );
  }
}