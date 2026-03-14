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
    setState(() {
      _favoriteJobs = jobs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // PostCard এর সাথে ম্যাচ করার জন্য ব্যাকগ্রাউন্ড সাদা করা হলো
      appBar: AppBar(
        title: const Text('Favorite Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteJobs.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadFavorites, // রিফ্রেশ করলে ফেভারিট লিস্ট আপডেট হবে
        color: Colors.black87,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(), // আইটেম কম থাকলেও রিফ্রেশ করা যাবে
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: _favoriteJobs.length,
          itemBuilder: (context, index) {
            final job = _favoriteJobs[index];

            // ================= এখানেই আপনার PostCard ব্যবহার করা হয়েছে =================
            return PostCard(
              post: job,
              fallbackCategoryName: 'Saved Job',
            );
            // =========================================================================

          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'কোনো ফেভারিট জব নেই',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'আপনার পছন্দের সার্কুলারগুলো সেভ করে রাখুন',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}