import 'dart:convert';

import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchList(String url) async {
    final parsedUrl = Uri.parse(url);
    final uri = parsedUrl.replace(
      queryParameters: {
        ...parsedUrl.queryParameters,
        'token': ApiUrls.token,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${ApiUrls.token}',
        'x-api-token': ApiUrls.token,
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final body = json.decode(response.body);

    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      final candidates = [
        body['data'],
        body['results'],
        body['items'],
        body['posts'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    return [];
  }
}
