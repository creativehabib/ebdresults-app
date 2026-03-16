class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final String? postId; // সংশ্লিষ্ট জবের আইডি রাখার জন্য এটি যুক্ত করা হলো
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.postId, // এটি অপশনাল হতে পারে
    this.isRead = false,
  });

  // JSON এ কনভার্ট করার জন্য
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'dateTime': dateTime.toIso8601String(),
    'postId': postId, // ফিল্ডটি যুক্ত করা হয়েছে
    'isRead': isRead,
  };

  // JSON থেকে মডেলে কনভার্ট করার জন্য
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'],
    title: json['title'],
    message: json['message'],
    dateTime: DateTime.parse(json['dateTime']),
    postId: json['postId'], // ফিল্ডটি যুক্ত করা হয়েছে
    isRead: json['isRead'] ?? false,
  );
}