import 'package:ebdresults/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel post;

  const JobDetailsScreen({super.key, required this.post});

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
    if (parsedDate == null) {
      return rawDate;
    }
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  Future<void> _openSourceLink() async {
    final uri = Uri.tryParse(post.link);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final description = _cleanHtml(post.content.isNotEmpty ? post.content : post.excerpt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 14),
          Text(
            _cleanHtml(post.title),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(post.date),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          Text(
            description.isNotEmpty ? description : 'এই পোস্টের কোনো বর্ণনা পাওয়া যায়নি।',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          if (post.link.isNotEmpty) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _openSourceLink,
              icon: const Icon(Icons.open_in_new),
              label: const Text('মূল পোস্ট দেখুন'),
            ),
          ],
        ],
      ),
    );
  }
}
