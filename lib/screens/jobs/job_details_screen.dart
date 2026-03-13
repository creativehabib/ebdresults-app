import 'package:ebdresults/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:ebdresults/screens/web_view_screen.dart';
import 'package:share_plus/share_plus.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel post;

  const JobDetailsScreen({super.key, required this.post});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  // স্ক্রল ট্র্যাক করার জন্য কন্ট্রোলার
  late ScrollController _scrollController;
  bool _isScrolled = false; // স্ক্রল হয়েছে কিনা তা চেক করার জন্য

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // স্ক্রল লিসেনার অ্যাড করা হলো
    _scrollController.addListener(() {
      // যদি স্ক্রল ২০ পিক্সেলের বেশি নিচে নামে
      if (_scrollController.offset > 20) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else {
        // যদি আবার একদম উপরে চলে আসে
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });
  }

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
    if (parsedDate == null) {
      return rawDate;
    }
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final htmlContent = widget.post.content.isNotEmpty ? widget.post.content : widget.post.excerpt;
    final String cleanPostTitle = _cleanTitle(widget.post.title);

    return Scaffold(
      backgroundColor: Colors.white,

      // ================= আপডেট করা AppBar =================
      appBar: AppBar(
        // স্ক্রল হলে ব্যাকগ্রাউন্ড কালার পরিবর্তন হবে
        backgroundColor: _isScrolled ? Colors.blue.shade50 : Colors.white,
        // স্ক্রল হলে নিচে হালকা শ্যাডো দেখাবে
        elevation: _isScrolled ? 2 : 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        // সুন্দর অ্যানিমেশনের জন্য AnimatedContainer-এর মতো কাজ করবে AppBar ডিফল্টভাবেই
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () {},
          ),
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
      // ====================================================

      body: SingleChildScrollView(
        controller: _scrollController, // কন্ট্রোলারটি এখানে যুক্ত করা হলো
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(
                      url: url,
                      title: 'Link',
                    ),
                  ),
                );
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