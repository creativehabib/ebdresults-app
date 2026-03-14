import 'dart:convert';
import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // ১. মেইন এপিআই রিকোয়েস্ট ফাংশন (Internal use)
  // এটি সরাসরি জেসন বডি রিটার্ন করবে (লিস্ট বা ম্যাপ যাই হোক)
  static Future<dynamic> _makeRequest(String endpoint) async {
    final url = endpoint.startsWith('http') ? endpoint : "${ApiUrls.base}/$endpoint";
    final uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiUrls.token}',
          'x-api-token': ApiUrls.token,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint("API Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API Error on $endpoint: $e");
    }
    return null;
  }

  // ২. সিঙ্গেল পোস্টের জন্য (এটি Map<String, dynamic> রিটার্ন করবে)
  static Future<Map<String, dynamic>?> fetchSingle(String endpoint) async {
    final body = await _makeRequest(endpoint);

    if (body == null) return null;

    // যদি রেসপন্স সরাসরি ম্যাপ হয়
    if (body is Map<String, dynamic>) {
      // যদি লারাভেলের 'data' কী-র ভেতরে মেইন ডাটা থাকে
      if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      return body;
    }

    // যদি কোনোভাবে এটি লিস্ট হিসেবে আসে, তবে প্রথম আইটেমটি রিটার্ন করবে
    if (body is List && body.isNotEmpty) {
      return body.first as Map<String, dynamic>;
    }

    return null;
  }

  // ৩. পোস্ট লিস্টের জন্য (এটি List<dynamic> রিটার্ন করবে)
  static Future<List<dynamic>> fetchList(String url) async {
    final body = await _makeRequest(url);
    if (body == null) return [];
    return _extractList(body);
  }

  // জনপ্রিয় পোস্ট ফেচ করা
  static Future<List<dynamic>> fetchPopularPosts({int perPage = 10}) {
    return fetchList(ApiUrls.popularPosts(perPage: perPage));
  }

  // সর্বশেষ আপডেট করা পোস্ট ফেচ করা
  static Future<List<dynamic>> fetchLastModifiedPosts({int perPage = 10}) {
    return fetchList(ApiUrls.lastModifiedPosts(perPage: perPage));
  }

  // ৪. জেসন বডি থেকে লিস্ট এক্সট্রাক্ট করার লজিক
  static List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      // এই কি-গুলোর মধ্যে কোনোটি লিস্ট কি না তা চেক করা হচ্ছে
      final candidates = [
        body['data'],
        body['results'],
        body['items'],
        body['posts'],
        body['categories'],
        body['tags'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }

      // যদি ম্যাপটি খালি না হয় এবং কোনো লিস্ট না পাওয়া যায়, তবে ম্যাপটিকে লিস্টে পুরে দেওয়া হচ্ছে
      if (body.isNotEmpty && !body.containsKey('data')) {
        return [body];
      }
    }

    return [];
  }
}