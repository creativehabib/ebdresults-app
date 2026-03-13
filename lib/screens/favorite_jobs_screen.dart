import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/screens/jobs/job_details_screen.dart';
import 'package:ebdresults/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String _cleanHtml(String rawText) {
    return rawText.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
  }

  String _formatDate(String rawDate) {
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return rawDate;
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text('Favorite Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteJobs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _favoriteJobs.length,
        itemBuilder: (context, index) {
          final job = _favoriteJobs[index];
          return _buildJobCard(job);
        },
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

  Widget _buildJobCard(JobModel job) {
    return GestureDetector(
      onTap: () async {
        // ডিটেইলস স্ক্রিনে যাওয়ার পর ব্যাক করলে লিস্ট আবার আপডেট হবে (যাতে রিমুভ করলে গায়েব হয়ে যায়)
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailsScreen(post: job)),
        );
        _loadFavorites();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_formatDate(job.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 70,
                height: 70,
                child: job.imageUrl.isNotEmpty
                    ? Image.network(job.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200))
                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}