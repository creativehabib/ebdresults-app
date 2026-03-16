import 'dart:convert';
import 'package:ebdresults/models/job_model.dart';
import 'package:ebdresults/services/favorite_service.dart';
import 'package:ebdresults/services/connectivity_service.dart'; // যুক্ত করা হয়েছে
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ebdresults/screens/home/category_post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // যুক্ত করা হয়েছে

class JobDetailsScreen extends StatefulWidget {
  final JobModel post;

  const JobDetailsScreen({super.key, required this.post});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isFavorite = false;
  bool _isOffline = false; // অফলাইন স্ট্যাটাস চেক

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _handleOfflineCaching(); // ক্যাশিং হ্যান্ডলার
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await FavoriteService.isFavorite(widget.post);
    if (mounted) {
      setState(() {
        _isFavorite = status;
      });
    }
  }

  // ডাটা ক্যাশ করা এবং কানেক্টিভিটি চেক করা
  Future<void> _handleOfflineCaching() async {
    bool connected = await ConnectivityService.isConnected();
    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'cached_job_details_${widget.post.id}';

    if (connected) {
      await prefs.setString(cacheKey, json.encode(widget.post.toJson()));
      if (mounted) setState(() => _isOffline = false);
    } else {
      if (mounted) setState(() => _isOffline = true);
    }
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
    // অফলাইনে লিংক ওপেন করা ব্লক করা হয়েছে
    bool connected = await ConnectivityService.isConnected();
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংক ওপেন করতে ইন্টারনেট সংযোগ লাগবে!')),
        );
      }
      return;
    }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final htmlContent = widget.post.content.isNotEmpty ? widget.post.content : widget.post.excerpt;
    final String cleanPostTitle = _cleanTitle(widget.post.title);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 230.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
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
                          backgroundColor: isDark ? theme.primaryColor : Colors.black87,
                          content: Text(_isFavorite ? 'ফেভারিট থেকে রিমুভ করা হয়েছে' : 'ফেভারিট এ সেভ করা হয়েছে!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
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
                  Container(color: isDark ? theme.scaffoldBackgroundColor : const Color(0xfff1f5f9)),

                  if (widget.post.imageUrl.isNotEmpty)
                    Image.network(
                      widget.post.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60, color: isDark ? Colors.white24 : Colors.grey),
                    )
                  else
                    Icon(Icons.image, size: 60, color: isDark ? Colors.white24 : Colors.grey),

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
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // অফলাইন মোড ইন্ডিকেটর বার (নতুন লজিক)
                    if (_isOffline)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "অফলাইন মোড: সংরক্ষিত ডাটা দেখাচ্ছেন",
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_isOffline) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("অফলাইনে ক্যাটাগরি ব্রাউজ করা যাবে না")));
                            return;
                          }
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
                            color: theme.primaryColor,
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.authorName,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.post.date),
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),

                        IconButton(
                          icon: Icon(Icons.share_outlined, color: isDark ? Colors.white70 : Colors.grey.shade700, size: 22),
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
                    Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                    const SizedBox(height: 20),

                    HtmlWidget(
                      htmlContent.isNotEmpty ? htmlContent : '<p>এই পোস্টের কোনো বর্ণনা পাওয়া যায়নি।</p>',
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        height: 1.8,
                        color: isDark ? const Color(0xffcbd5e1) : const Color(0xff475569),
                      ),
                      customStylesBuilder: (element) {
                        if (element.localName == 'a') return {'color': '#60a5fa', 'text-decoration': 'none'};
                        if (element.localName == 'table') return {'border': '1px solid ${isDark ? "#334155" : "#e0e0e0"}', 'width': '100%'};
                        if (element.localName == 'th') return {'background-color': isDark ? '#1e293b' : '#f8fafc', 'padding': '10px'};
                        if (element.localName == 'td') return {'padding': '10px', 'border': '1px solid ${isDark ? "#334155" : "#e0e0e0"}'};
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