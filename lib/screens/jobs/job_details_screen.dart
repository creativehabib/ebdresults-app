import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/favorite_service.dart'; // ফেভারিট সার্ভিস ইমপোর্ট করা হয়েছে
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel post;

  const JobDetailsScreen({super.key, required this.post});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // ================= ফেভারিটের জন্য নতুন ভেরিয়েবল =================
  bool _isFavorite = false;
  // ================================================================

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus(); // শুরুতে ফেভারিট স্ট্যাটাস চেক করবে

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20) {
        if (!_isScrolled) setState(() => _isScrolled = true);
      } else {
        if (_isScrolled) setState(() => _isScrolled = false);
      }
    });
  }

  // ================= ফেভারিট স্ট্যাটাস চেক করার ফাংশন =================
  Future<void> _checkFavoriteStatus() async {
    final status = await FavoriteService.isFavorite(widget.post);
    setState(() {
      _isFavorite = status;
    });
  }
  // ====================================================================

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _cleanTitle(String rawText) {
    return rawText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  String _formatDate(String rawDate) {
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return rawDate;
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  // ================= লিংকে ক্লিক করলে ওপেন করার আল্টিমেট ও সিকিউর সল্যুশন =================
  Future<void> _openLinkInternally(String link) async {
    try {
      String secureUrl = link.trim();
      if (secureUrl.startsWith('http://')) {
        secureUrl = secureUrl.replaceFirst('http://', 'https://');
      }

      final Uri? url = Uri.tryParse(secureUrl);
      if (url == null) throw 'Invalid URL';

      final String urlLower = secureUrl.toLowerCase();

      final bool isDriveOrShortLink = urlLower.contains('drive.google.com') ||
          urlLower.contains('docs.google.com') ||
          urlLower.contains('forms.gle') ||
          urlLower.contains('bit.ly') ||
          urlLower.contains('cutt.ly') ||
          urlLower.contains('tinyurl.com');

      if (isDriveOrShortLink) {
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('আপনার ফোনে ব্রাউজার বা ড্রাইভ অ্যাপ পাওয়া যাচ্ছে না')),
          );
        }
      } else {
        bool launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);

        if (!launched) {
          launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        }

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('লিংকটি কোনোভাবেই ওপেন করা যাচ্ছে না')),
          );
        }
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংকটিতে কোনো সমস্যা আছে')),
        );
      }
    }
  }
  // =====================================================================================

  @override
  Widget build(BuildContext context) {
    final htmlContent = widget.post.content.isNotEmpty ? widget.post.content : widget.post.excerpt;
    final String cleanPostTitle = _cleanTitle(widget.post.title);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: _isScrolled ? Colors.blue.shade50 : Colors.white,
        elevation: _isScrolled ? 2 : 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // ================= ফেভারিট বাটন আপডেট করা হলো =================
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black87,
            ),
            onPressed: () async {
              await FavoriteService.toggleFavorite(widget.post);
              _checkFavoriteStatus(); // বাটনের রঙ পরিবর্তন করার জন্য স্ট্যাটাস আপডেট

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite ? 'ফেভারিট থেকে রিমুভ করা হয়েছে' : 'ফেভারিট এ সেভ করা হয়েছে!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          // ================================================================
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () async {
              final String shareText = '$cleanPostTitle\n\nবিস্তারিত জানতে ক্লিক করুন:\n${widget.post.link}';
              try {
                final box = context.findRenderObject() as RenderBox?;
                await Share.share(
                  shareText,
                  subject: cleanPostTitle,
                  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                );
              } catch (e) {
                debugPrint('Share Error: $e');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffe8eaf6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.post.firstCategoryName.isNotEmpty ? widget.post.firstCategoryName : 'Job Circular',
                style: const TextStyle(color: Color(0xff5c55a5), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cleanPostTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  _formatDate(widget.post.date),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.views} views',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (widget.post.imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            HtmlWidget(
              htmlContent.isNotEmpty ? htmlContent : '<p>এই পোস্টের কোনো বর্ণনা পাওয়া যায়নি।</p>',
              textStyle: const TextStyle(
                fontSize: 16.0,
                height: 1.6,
                color: Colors.black87,
              ),
              customStylesBuilder: (element) {
                if (element.localName == 'a') {
                  return {'color': '#2979ff', 'text-decoration': 'none'};
                }
                if (element.localName == 'table') {
                  return {'border': '1px solid #e0e0e0', 'width': '100%'};
                }
                if (element.localName == 'th') {
                  return {'background-color': '#f5f5f5', 'padding': '8px'};
                }
                if (element.localName == 'td') {
                  return {'padding': '8px', 'border': '1px solid #e0e0e0'};
                }
                if (element.localName == 'img') {
                  return {'margin-top': '10px', 'margin-bottom': '10px'};
                }
                return null;
              },
              onTapUrl: (url) async {
                await _openLinkInternally(url);
                return true;
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}