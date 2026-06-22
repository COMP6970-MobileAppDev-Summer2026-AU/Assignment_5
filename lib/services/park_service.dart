// =============================================================================
// services/park_service.dart
// NPS API — fetch parks by state code
// Get your free API key at: https://www.nps.gov/subjects/developer/get-started.htm
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/park_model.dart';

class ParkService {
  static const String _baseUrl = 'https://developer.nps.gov/api/v1/parks';

  // ⚠️  Replace with your NPS API key from:
  // https://www.nps.gov/subjects/developer/get-started.htm
  static const String _apiKey = 'P2UzqPBqAQxj9gfnPaG5VCJ9RjbCd8Vdenbgh3cT';

  static const int _limit = 50;

  /// Fetch all parks for a given US state code (e.g. 'CA', 'WY')
  Future<List<ParkModel>> fetchParksByState(String stateCode) async {
    final uri = Uri.parse(
      '$_baseUrl?stateCode=$stateCode&limit=$_limit&api_key=$_apiKey',
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parkResponse = ParkResponse.fromJson(json);
      return parkResponse.data;
    } else {
      throw Exception(
        'API error ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  /// Fetch a single park by park code (e.g. 'yose' for Yosemite)
  Future<ParkModel?> fetchParkByCode(String parkCode) async {
    final uri = Uri.parse(
      '$_baseUrl?parkCode=$parkCode&api_key=$_apiKey',
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parkResponse = ParkResponse.fromJson(json);
      return parkResponse.data.isNotEmpty ? parkResponse.data.first : null;
    } else {
      throw Exception('API error ${response.statusCode}');
    }
  }
}
