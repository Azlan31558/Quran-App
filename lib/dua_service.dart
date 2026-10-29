import 'dart:convert';

import 'package:http/http.dart' as http;

class DuaService {
  static const _host = 'www.hisnmuslim.com';
  static const _timeout = Duration(seconds: 20);
  static const _commonDuaTitles = <int, String>{
    27: 'صبح و شام کے اذکار',
    28: 'سونے سے پہلے کی دعا',
    1: 'بیدار ہونے کی دعا',
    6: 'بیت الخلا میں داخل ہونے کی دعا',
    7: 'بیت الخلا سے نکلنے کی دعا',
    10: 'گھر سے نکلنے کی دعا',
    11: 'گھر میں داخل ہونے کی دعا',
    12: 'مسجد جانے کی دعا',
    15: 'اذان کے بعد کی دعا',
    25: 'نماز کے بعد کے اذکار',
    68: 'روزہ افطار کرنے کی دعا',
    69: 'کھانے سے پہلے کی دعا',
    70: 'کھانے کے بعد کی دعا',
  };

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http
        .get(Uri.https(_host, '/api/en/husn_en.json'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Dua categories unavailable (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['English'] is! List) {
      throw const FormatException('Unexpected Dua categories response.');
    }

    final categories = (decoded['English'] as List)
        .whereType<Map>()
        .map((item) {
          final id = int.tryParse(item['ID']?.toString() ?? '');
          return <String, dynamic>{
            'id': id,
            'title': _commonDuaTitles[id] ?? '',
            'englishTitle': item['TITLE']?.toString().trim() ?? '',
            'textUrl': item['TEXT']?.toString() ?? '',
          };
        })
        .where((category) {
          return category['id'] != null &&
              _commonDuaTitles.containsKey(category['id']) &&
              (category['textUrl'] as String).isNotEmpty;
        })
        .toList();

    final displayOrder = _commonDuaTitles.keys.toList();
    categories.sort(
      (a, b) => displayOrder
          .indexOf(a['id'] as int)
          .compareTo(displayOrder.indexOf(b['id'] as int)),
    );
    return categories;
  }

  static Future<Map<String, dynamic>> getCategoryDuas(String textUrl) async {
    final uri = Uri.parse(textUrl);
    final secureUri = uri.scheme == 'http' ? uri.replace(scheme: 'https') : uri;
    final response = await http.get(secureUri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Duas unavailable (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Unexpected Dua response.');
    }

    final categoryEntry = decoded.entries.firstWhere(
      (entry) => entry.value is List,
      orElse: () => throw const FormatException('Dua list is missing.'),
    );

    final duas = (categoryEntry.value as List).whereType<Map>().map((item) {
      final id = int.tryParse(item['ID']?.toString() ?? '');
      final arabic = item['ARABIC_TEXT']?.toString() ?? '';
      return <String, dynamic>{
        'id': id,
        'arabic': arabic,
        'transliteration':
            item['LANGUAGE_ARABIC_TRANSLATED_TEXT']?.toString() ?? '',
        'translation': item['TRANSLATED_TEXT']?.toString() ?? '',
        'repeat': item['REPEAT']?.toString() ?? '1',
        'arabicAudioUrl': id != null && arabic.trim().isNotEmpty
            ? Uri.https(_host, '/audio/ar/$id.mp3').toString()
            : null,
      };
    }).toList();

    return {'title': categoryEntry.key.toString(), 'duas': duas};
  }
}
