import 'dart:convert';

import 'package:ebdresults/core/constants/api_urls.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchList(String url) async {
    final uri = Uri.parse(url).replace(
      queryParameters: {
        ...Uri.parse(url).queryParameters,
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

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is List) {
        return body;
      }
    }

    return [];
  }
}
