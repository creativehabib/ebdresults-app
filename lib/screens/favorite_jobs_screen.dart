import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:ebdresults/widgets/post_card.dart';

class FavoriteJobsScreen extends StatefulWidget {
  const FavoriteJobsScreen({super.key});

  @override
  State<FavoriteJobsScreen> createState() => _FavoriteJobsScreenState();
}

class _FavoriteJobsScreenState extends State<FavoriteJobsScreen> {
  List<JobModel> _favoriteJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final jobs = await FavoriteService.getFavoriteJobs();
    if (mounted) {
      setState(() {
        _favoriteJobs = jobs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor এখন থিম থেকে অটোমেটিক নেবে
      appBar: AppBar(
        title: Text(
            'Favorite Jobs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,
        scrolledUnderElevation: 0,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black12,
        // ব্যাক বাটন কালার অ্যাডজাস্টমেন্ট
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _favoriteJobs.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        color: theme.primaryColor,
        backgroundColor: isDark ? theme.cardTheme.color : Colors.white,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: _favoriteJobs.length,
          itemBuilder: (context, index) {
            final job = _favoriteJobs[index];

            // PostCard এখন নিজেই থিম সাপোর্ট করে, তাই শুধু কল করলেই হবে
            return PostCard(
              post: job,
              fallbackCategoryName: 'Saved Job',
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.favorite_border,
              size: 80,
              color: isDark ? Colors.white10 : Colors.grey.shade300
          ),
          const SizedBox(height: 16),
          Text(
            'কোনো ফেভারিট জব নেই',
            style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'আপনার পছন্দের সার্কুলারগুলো সেভ করে রাখুন',
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey.shade500
            ),
          ),
        ],
      ),
    );
  }
}