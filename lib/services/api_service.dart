import 'dart:convert';

import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchList(String url) async {
    final parsedUrl = Uri.parse(url);

    final urlsToTry = <Uri>[
      parsedUrl.replace(
        queryParameters: {
          ...parsedUrl.queryParameters,
          'token': ApiUrls.token,
        },
      ),
      parsedUrl,
    ];

    for (final uri in urlsToTry) {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiUrls.token}',
          'x-api-token': ApiUrls.token,
        },
      );

      if (response.statusCode != 200) {
        continue;
      }

      final body = json.decode(response.body);
      final extracted = _extractList(body);
      if (extracted.isNotEmpty) {
        return extracted;
      }
    }

    return [];
  }

  static Future<List<dynamic>> fetchPopularPosts({int perPage = 10}) {
    return fetchList(ApiUrls.popularPosts(perPage: perPage));
  }

  static Future<List<dynamic>> fetchPostsByCategory(
    int categoryId, {
    int perPage = 10,
  }) {
    return fetchList(ApiUrls.postsByCategory(categoryId, perPage: perPage));
  }

  static Future<List<dynamic>> fetchLastModifiedPosts({int perPage = 10}) {
    return fetchList(ApiUrls.lastModifiedPosts(perPage: perPage));
  }

  static List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
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

      if (body.isNotEmpty) {
        return [body];
      }
    }

    return [];
  }
}
