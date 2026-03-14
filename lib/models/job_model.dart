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
  final String firstCategoryName;
  final String views;
  final String authorName;

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
    required this.authorName,
  });

  // লোকাল ডাটাবেসে (Favorite) সেভ করার জন্য
  Map<String, dynamic> toJson() {
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
      'name': title,
      'description': excerpt,
      'content': content,
      'published_at': date,
      'image_url': imageUrl,
      'slug': slug,
      'categories': categoriesData,
      'tags': tagIds.map((id) => {'id': id}).toList(),
      'views': views,
      'author': {
        'name': authorName,
      }
    };
  }

  // Laravel API থেকে ডাটা রিসিভ করার জন্য
  factory JobModel.fromJson(Map<String, dynamic> json) {

    // ১. ক্যাটাগরি আইডি এবং প্রথম ক্যাটাগরির নাম বের করা
    List<int> catIds = [];
    String catName = 'Job Circular'; // ডিফল্ট নাম

    if (json['categories'] != null && json['categories'] is List) {
      final categoriesList = json['categories'] as List;
      if (categoriesList.isNotEmpty) {
        catName = categoriesList[0]['name']?.toString() ?? 'Job Circular';
        catIds = categoriesList
            .map((c) => int.tryParse(c['id'].toString()) ?? 0)
            .where((id) => id > 0)
            .toList();
      }
    }

    // ২. ট্যাগ আইডি বের করা
    List<int> tIds = [];
    if (json['tags'] != null && json['tags'] is List) {
      tIds = (json['tags'] as List)
          .map((t) => int.tryParse(t['id'].toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    // ৩. অথর (Author) এর নাম বের করা
    String author = 'Admin';
    if (json['author'] != null && json['author'] is Map) {
      author = json['author']['name']?.toString() ?? 'Admin';
    }

    // ৪. ইমেজ লিংক বের করার ১০০% কার্যকরী লজিক
    String extractImage(Map<String, dynamic> data) {
      final imgUrl = data['image_url']?.toString() ?? '';
      if (imgUrl.isNotEmpty && imgUrl.startsWith('http')) return imgUrl;

      final img = data['image']?.toString() ?? '';
      if (img.isNotEmpty && img.startsWith('http')) return img;

      return ''; // যদি কোনো ছবি না থাকে
    }

    // ৫. স্লাগ এবং লিংক জেনারেট করা
    final String slugStr = (json['slug'] ?? '').toString();
    final String linkStr = slugStr.isNotEmpty ? 'https://ebdresults.com/$slugStr' : '';

    return JobModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: (json['name'] ?? json['title'] ?? '').toString(),
      excerpt: (json['description'] ?? json['excerpt'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      date: (json['published_at'] ?? json['date'] ?? '').toString(),
      link: linkStr,
      imageUrl: extractImage(json), // আপডেট করা ফাংশনটি কল করা হলো
      slug: slugStr,
      categoryIds: catIds,
      tagIds: tIds,
      firstCategoryName: catName,
      views: (json['views'] ?? '0').toString(),
      authorName: author,
    );
  }
}