import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ebdresults/screens/home/category_post_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel post;

  const JobDetailsScreen({super.key, required this.post});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await FavoriteService.isFavorite(widget.post);
    setState(() {
      _isFavorite = status;
    });
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
    return DateFormat('dd MMM, yyyy').format(parsedDate);
  }

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
            const SnackBar(content: Text('অ্যাপটি পাওয়া যাচ্ছে না')),
          );
        }
      } else {
        bool launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
        if (!launched) {
          launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('লিংকটি ওপেন করা যাচ্ছে না')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংকটিতে সমস্যা আছে')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final htmlContent = widget.post.content.isNotEmpty ? widget.post.content : widget.post.excerpt;
    final String cleanPostTitle = _cleanTitle(widget.post.title);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 230.0,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff0e1726).withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    await FavoriteService.toggleFavorite(widget.post);
                    _checkFavoriteStatus();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? 'ফেভারিট থেকে রিমুভ করা হয়েছে' : 'ফেভারিট এ সেভ করা হয়েছে!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xff0e1726).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ইমেজের পেছনে একটি হালকা কালার দেওয়া হলো যাতে ছবি ছোট হলে খারাপ না লাগে
                  Container(color: const Color(0xfff1f5f9)),

                  if (widget.post.imageUrl.isNotEmpty)
                    Image.network(
                      widget.post.imageUrl,
                      // ================= Aspect Ratio ঠিক রাখতে contain ব্যবহার করা হলো =================
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60, color: Colors.grey),
                    )
                  else
                    const Icon(Icons.image, size: 60, color: Colors.grey),

                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              child: Padding(
                // ================= উপরের প্যাডিং 20 থেকে বাড়িয়ে 32 করা হলো =================
                padding: const EdgeInsets.only(top: 32.0, left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.post.categoryIds.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryPostScreen(
                                  categoryId: widget.post.categoryIds.first,
                                  categoryName: widget.post.firstCategoryName.isNotEmpty
                                      ? widget.post.firstCategoryName
                                      : 'Job Circular',
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xff1e293b),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.post.firstCategoryName.isNotEmpty ? widget.post.firstCategoryName : 'Job Circular',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 10),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      cleanPostTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                        color: Color(0xff334155),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.authorName,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.post.date),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),

                        IconButton(
                          icon: Icon(Icons.share_outlined, color: Colors.grey.shade700, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final String shareText = '$cleanPostTitle\n\nবিস্তারিত জানতে ক্লিক করুন:\n${widget.post.link}';
                            await Share.share(shareText, subject: cleanPostTitle);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 20),

                    HtmlWidget(
                      htmlContent.isNotEmpty ? htmlContent : '<p>এই পোস্টের কোনো বর্ণনা পাওয়া যায়নি।</p>',
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        height: 1.8,
                        color: Color(0xff475569),
                      ),
                      customStylesBuilder: (element) {
                        if (element.localName == 'a') return {'color': '#2979ff', 'text-decoration': 'none'};
                        if (element.localName == 'table') return {'border': '1px solid #e0e0e0', 'width': '100%'};
                        if (element.localName == 'th') return {'background-color': '#f8fafc', 'padding': '10px'};
                        if (element.localName == 'td') return {'padding': '10px', 'border': '1px solid #e0e0e0'};
                        if (element.localName == 'img') return {'margin-top': '15px', 'margin-bottom': '15px', 'border-radius': '8px'};
                        return null;
                      },
                      onTapUrl: (url) async {
                        await _openLinkInternally(url);
                        return true;
                      },
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}