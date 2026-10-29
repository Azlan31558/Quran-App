import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> fetchAllahNameAudioUrl(String number) async {
  final uri = Uri.https(
    'asmaul-husna-api-coral.vercel.app',
    '/api/asmaul-husna',
    {'id': number},
  );
  final response = await http.get(uri).timeout(const Duration(seconds: 15));

  if (response.statusCode != 200) {
    throw StateError('Audio lookup failed with status ${response.statusCode}.');
  }

  final data = jsonDecode(response.body);
  if (data is! Map || data['audio_url'] is! String) {
    throw const FormatException('Audio URL is missing from the response.');
  }

  return data['audio_url'] as String;
}
