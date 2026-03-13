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

  // নতুন যোগ করা ভেরিয়েবল
  final String firstCategoryName;
  final String views;

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
    required this.firstCategoryName,
    required this.views,
  });

  // ================= নতুন যোগ করা toJson() মেথড =================
  // লোকাল ডাটাবেসে সেভ করার জন্য এই মেথডটি প্রয়োজন
  Map<String, dynamic> toJson() {
    // API-এর মতো স্ট্রাকচার তৈরি করার জন্য ক্যাটাগরির লিস্ট বানানো হচ্ছে
    List<Map<String, dynamic>> categoriesData = [];
    if (categoryIds.isNotEmpty) {
      categoriesData.add({'id': categoryIds.first, 'name': firstCategoryName});
      for (int i = 1; i < categoryIds.length; i++) {
        categoriesData.add({'id': categoryIds[i]});
      }
    } else {
      categoriesData.add({'name': firstCategoryName});
    }

    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'date': date,
      'link': link,
      'image_url': imageUrl,
      'slug': slug,
      'categories': categoriesData,
      'tags': tagIds,
      'views': views,
    };
  }
  // =============================================================

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

    // আপডেট করা pickIntList: এটি এখন List of ID এবং List of Object দুটোই হ্যান্ডেল করতে পারবে
    List<int> pickIntList(dynamic value) {
      if (value is List) {
        return value.map((e) {
          if (e is num) return e.toInt();
          if (e is Map<String, dynamic> && e['id'] != null) {
            return int.tryParse(e['id'].toString()) ?? 0;
          }
          return 0;
        }).where((id) => id > 0).toList();
      }
      return [];
    }

    // প্রথম ক্যাটাগরির নাম বের করার ফাংশন
    String extractCategoryName(dynamic value) {
      if (value is List && value.isNotEmpty) {
        final firstItem = value.first;
        if (firstItem is Map<String, dynamic> && firstItem['name'] != null) {
          return firstItem['name'].toString();
        }
      }
      return 'Update'; // যদি ক্যাটাগরি না থাকে তবে ডিফল্ট নাম
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

    final excerpt = pickText(json['excerpt'] ?? json['description']);
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

      // নতুন ডেটাগুলো মডেলে পাস করা হলো
      firstCategoryName: extractCategoryName(json['categories']),
      views: (json['views'] ?? '0').toString(),
    );
  }
}