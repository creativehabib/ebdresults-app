class JobModel {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String link;
  final String imageUrl;
  final String slug;
  final List<int> categoryIds;
  final List<int> tagIds;

  const JobModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.link,
    required this.imageUrl,
    required this.slug,
    required this.categoryIds,
    required this.tagIds,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    String pickText(dynamic value) {
      if (value is String) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final rendered = value['rendered'];
        if (rendered is String) {
          return rendered;
        }
      }
      return '';
    }

    List<int> pickIntList(dynamic value) {
      if (value is List) {
        return value.whereType<num>().map((e) => e.toInt()).toList();
      }
      return [];
    }

    String pickImage(dynamic value) {
      if (value is String) {
        return value;
      }

      if (value is Map<String, dynamic>) {
        final url = value['url'] ?? value['src'] ?? value['image_url'];
        if (url is String) {
          return url;
        }
      }

      return '';
    }

    String buildLink(Map<String, dynamic> map) {
      final raw = (map['link'] ?? map['url'] ?? '').toString();
      if (raw.isNotEmpty) {
        return raw;
      }

      final slug = (map['slug'] ?? '').toString();
      if (slug.isNotEmpty) {
        return 'https://ebdresults.com/$slug';
      }

      return '';
    }

    final excerpt = pickText(json['excerpt']);
    final content = pickText(json['content']);

    return JobModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: pickText(json['title']).isNotEmpty
          ? pickText(json['title'])
          : (json['name'] ?? '').toString(),
      excerpt: excerpt.isNotEmpty ? excerpt : content,
      content: content,
      date: (json['date'] ?? json['published_at'] ?? '').toString(),
      link: buildLink(json),
      imageUrl: pickImage(json['image_url']).isNotEmpty
          ? pickImage(json['image_url'])
          : pickImage(json['image']),
      slug: (json['slug'] ?? '').toString(),
      categoryIds: pickIntList(json['categories']),
      tagIds: pickIntList(json['tags']),
    );
  }
}
