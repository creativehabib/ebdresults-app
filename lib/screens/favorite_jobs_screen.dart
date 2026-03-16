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
      appBar: AppBar(
        title: Text(
            'Favorite Jobs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: isDark ? 0 : 1,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _favoriteJobs.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        color: theme.primaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: _favoriteJobs.length,
          itemBuilder: (context, index) {
            final job = _favoriteJobs[index];

            // Dismissible যোগ করা হয়েছে যাতে স্লাইড করে রিমুভ করা যায়
            return Dismissible(
              key: Key(job.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.redAccent,
                child: const Icon(Icons.delete_forever, color: Colors.white),
              ),
              onDismissed: (direction) async {
                await FavoriteService.toggleFavorite(job);
                setState(() {
                  _favoriteJobs.removeAt(index);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("ফেভারিট থেকে রিমুভ করা হয়েছে"), duration: Duration(seconds: 1)),
                  );
                }
              },
              child: InkWell(
                onTap: () {
                  // ডিটেইলস পেজ থেকে ফিরে আসলে লিস্ট আপডেট করার জন্য .then ব্যবহার করা হয়েছে
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostCard(post: job, fallbackCategoryName: 'Saved Job'), // আপনার ডিটেইলস পেজ কল করবেন এখানে
                    ),
                  ).then((_) => _loadFavorites());
                },
                child: PostCard(
                  post: job,
                  fallbackCategoryName: 'Saved Job',
                ),
              ),
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
          const Text(
            'আপনার পছন্দের সার্কুলারগুলো সেভ করে রাখুন',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}