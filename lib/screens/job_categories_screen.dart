import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:ebdresults/services/api_service.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Scaffold এখন থিম থেকে অটোমেটিক ব্যাকগ্রাউন্ড নেবে
      appBar: AppBar(
        title: Text(
            'Job Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            )
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black12,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
                'ক্যাটাগরি লোড করতে সমস্যা হয়েছে!',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 16)
            ),
            TextButton(
              onPressed: _fetchCategories,
              child: Text('আবার চেষ্টা করুন', style: TextStyle(color: theme.primaryColor)),
            )
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
          child: Text(
            'কোনো ক্যাটাগরি পাওয়া যায়নি।',
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          )
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2, // একটু অ্যাডজাস্ট করা হলো
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
              // থিমের কার্ড কালার ব্যবহার করা হয়েছে
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDark) // ডার্ক মোডে শ্যাডো দরকার নেই
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  ),
              ],
              border: isDark
                  ? Border.all(color: Colors.white10, width: 1)
                  : null, // ডার্ক মোডে হালকা বর্ডার
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // আইকন ব্যাকগ্রাউন্ড থিম অনুযায়ী
                    color: theme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      Icons.work_outline,
                      color: theme.primaryColor,
                      size: 28
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    category['name'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count > 0 ? '$count Posts' : 'Explore Jobs',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}