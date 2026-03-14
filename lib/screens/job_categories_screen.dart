import 'package:flutter/material.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/services/api_service.dart';
import 'home/category_post_screen.dart';

class JobCategoriesScreen extends StatefulWidget {
  const JobCategoriesScreen({super.key});

  @override
  State<JobCategoriesScreen> createState() => _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends State<JobCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // ================= API থেকে ক্যাটাগরি আনার আপডেট ফাংশন =================
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.fetchList(ApiUrls.categories);
      final List<Map<String, dynamic>> fetchedCategories = [];

      for (var item in response) {
        if (item is Map<String, dynamic>) {

          // API থেকে count বা post_count যেভাবেই আসুক, তা ইন্টিজারে কনভার্ট করে নেবে
          int postCount = 0;
          if (item['count'] != null) {
            postCount = int.tryParse(item['count'].toString()) ?? 0;
          } else if (item['post_count'] != null) {
            postCount = int.tryParse(item['post_count'].toString()) ?? 0;
          }

          fetchedCategories.add({
            'id': item['id'],
            'name': _cleanHtml(item['name'] ?? 'Unknown'),
            'count': postCount,
          });
        }
      }

      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  String _cleanHtml(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text('Job Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('ক্যাটাগরি লোড করতে সমস্যা হয়েছে!', style: TextStyle(fontSize: 16)),
            TextButton(
              onPressed: _fetchCategories,
              child: const Text('আবার চেষ্টা করুন'),
            )
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('কোনো ক্যাটাগরি পাওয়া যায়নি।'));
    }

    // গ্রিড ভিউ দিয়ে ক্যাটাগরিগুলো সাজানো
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final int count = category['count'];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryPostScreen(
                  categoryId: category['id'],
                  categoryName: category['name'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff5c55a5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.work_outline, color: Color(0xff5c55a5), size: 28),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category['name'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                // ================= স্মার্ট লজিক =================
                // যদি API থেকে 0 আসে, তাহলে "Explore Jobs" দেখাবে, দেখতে ভালো লাগবে
                Text(
                  count > 0 ? '$count Posts' : 'Explore Jobs',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                // ===============================================
              ],
            ),
          ),
        );
      },
    );
  }
}