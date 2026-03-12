class JobModel {
  final int id;
  final String title;
  final String excerpt;
  final String date;
  final String link;
  final List<int> categoryIds;
  final List<int> tagIds;

  const JobModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.date,
    required this.link,
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

    return JobModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: pickText(json['title']),
      excerpt: pickText(json['excerpt']),
      date: (json['date'] ?? '').toString(),
      link: (json['link'] ?? json['url'] ?? '').toString(),
      categoryIds: pickIntList(json['categories']),
      tagIds: pickIntList(json['tags']),
    );
  }
}
