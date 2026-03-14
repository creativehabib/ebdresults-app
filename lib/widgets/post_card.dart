import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/job_model.dart';
import '../screens/jobs/job_details_screen.dart';
// ================= ফেভারিট সার্ভিস ইমপোর্ট করা হলো =================
import '../services/favorite_service.dart';
// =================================================================

class PostCard extends StatefulWidget {
  final JobModel post;
  final String fallbackCategoryName;

  const PostCard({
    super.key,
    required this.post,
    this.fallbackCategoryName = 'Job Circular',
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // ফেভারিট চেক করার ফাংশন
  Future<void> _checkFavoriteStatus() async {
    final status = await FavoriteService.isFavorite(widget.post);
    if (mounted) {
      setState(() {
        _isFavorite = status;
      });
    }
  }

  String _cleanHtml(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(String rawDate) {
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return rawDate;
    return DateFormat('dd MMM, yyyy').format(parsedDate);
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ডিটেইলস স্ক্রিন থেকে ব্যাক করলে ফেভারিট আইকনের স্ট্যাটাস আপডেট করার জন্য .then ব্যবহার করা হয়েছে
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailsScreen(post: widget.post)),
        ).then((_) {
          _checkFavoriteStatus();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // বাম পাশের স্কোয়ার ইমেজ
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 100,
                height: 100,
                child: widget.post.imageUrl.isNotEmpty
                    ? Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 16),

            // ডান পাশের টেক্সট কন্টেন্ট
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.post.firstCategoryName.isNotEmpty
                              ? widget.post.firstCategoryName
                              : widget.fallbackCategoryName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // ================= ফেভারিট (Heart) আইকন ও ক্লিক লজিক =================
                      InkWell(
                        onTap: () async {
                          await FavoriteService.toggleFavorite(widget.post);
                          _checkFavoriteStatus();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isFavorite
                                    ? 'ফেভারিট থেকে রিমুভ করা হয়েছে'
                                    : 'ফেভারিট এ সেভ করা হয়েছে!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0), // ট্যাপ এরিয়া বড় করার জন্য
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: _isFavorite ? Colors.redAccent : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      // ======================================================================

                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    _cleanHtml(widget.post.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            widget.post.authorName,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.post.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}