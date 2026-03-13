import 'dart:convert';
import 'package:ebdresults/models/job_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_jobs';

  // সব ফেভারিট জব তুলে আনা
  static Future<List<JobModel>> getFavoriteJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jobsString = prefs.getString(_key);

    if (jobsString == null) return [];

    final List<dynamic> decodedData = json.decode(jobsString);
    return decodedData.map((e) => JobModel.fromJson(e)).toList();
  }

  // ফেভারিট অ্যাড বা রিমুভ করা
  static Future<void> toggleFavorite(JobModel job) async {
    final prefs = await SharedPreferences.getInstance();
    List<JobModel> favorites = await getFavoriteJobs();

    // চেক করছি জবটি আগে থেকেই সেভ করা আছে কিনা (আমরা link দিয়ে চেক করছি)
    final existingIndex = favorites.indexWhere((element) => element.link == job.link);

    if (existingIndex >= 0) {
      // যদি আগে থেকেই থাকে, তাহলে রিমুভ করে দেব (Unfavorite)
      favorites.removeAt(existingIndex);
    } else {
      // না থাকলে লিস্টে যোগ করব (Favorite)
      favorites.add(job);
    }

    // আবার শেয়ার্ড প্রেফারেন্সে সেভ করা
    final String encodedData = json.encode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encodedData);
  }

  // জবটি ফেভারিট করা আছে কিনা তা চেক করা
  static Future<bool> isFavorite(JobModel job) async {
    List<JobModel> favorites = await getFavoriteJobs();
    return favorites.any((element) => element.link == job.link);
  }
}