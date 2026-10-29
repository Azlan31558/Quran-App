import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuranService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  // 30 Paras (Juz) Metadata
  static const List<Map<String, dynamic>> juzList = [
    {
      "id": 1,
      "name": "Alif Laam Meem",
      "arabic": "الم",
      "start": "Al-Fatihah 1",
      "ayahs": 148,
    },
    {
      "id": 2,
      "name": "Sayaqool",
      "arabic": "سَيَقُولُ",
      "start": "Al-Baqarah 142",
      "ayahs": 111,
    },
    {
      "id": 3,
      "name": "Tilka'r Rusul",
      "arabic": "تِلْكَ الرُّسُلُ",
      "start": "Al-Baqarah 253",
      "ayahs": 126,
    },
    {
      "id": 4,
      "name": "Lan Tana Loo",
      "arabic": "لَنْ تَنَالُوا",
      "start": "Aal-i-Imraan 93",
      "ayahs": 131,
    },
    {
      "id": 5,
      "name": "Wal Mohsanat",
      "arabic": "وَالْمُحْصَنَاتُ",
      "start": "An-Nisaa 24",
      "ayahs": 124,
    },
    {
      "id": 6,
      "name": "La Yuhibbullah",
      "arabic": "لَا يُحِبُّ اللَّهُ",
      "start": "An-Nisaa 148",
      "ayahs": 110,
    },
    {
      "id": 7,
      "name": "Wa Iza Samiu",
      "arabic": "وَإِذَا سَمِعُوا",
      "start": "Al-Maaida 82",
      "ayahs": 149,
    },
    {
      "id": 8,
      "name": "Wa Lau Annana",
      "arabic": "وَلَوْ أَنَّنَا",
      "start": "Al-An'aam 111",
      "ayahs": 142,
    },
    {
      "id": 9,
      "name": "Qalal Malao",
      "arabic": "قَالَ الْمَلَأُ",
      "start": "Al-A'raaf 88",
      "ayahs": 159,
    },
    {
      "id": 10,
      "name": "Wa A'lamoo",
      "arabic": "وَاعْلَمُوا",
      "start": "Al-Anfaal 41",
      "ayahs": 127,
    },
    {
      "id": 11,
      "name": "Yatazeroon",
      "arabic": "يَعْتَذِرُونَ",
      "start": "At-Tawba 93",
      "ayahs": 151,
    },
    {
      "id": 12,
      "name": "Wa Mamin Da'abat",
      "arabic": "وَمَا مِنْ دَابَّةٍ",
      "start": "Hud 6",
      "ayahs": 170,
    },
    {
      "id": 13,
      "name": "Wa Ma Ubrioo",
      "arabic": "وَمَا أُبَرِّئُ",
      "start": "Yusuf 53",
      "ayahs": 154,
    },
    {
      "id": 14,
      "name": "Rubama",
      "arabic": "رُبَمَا",
      "start": "Al-Hijr 1",
      "ayahs": 227,
    },
    {
      "id": 15,
      "name": "Subhanallazi",
      "arabic": "سُبْحَانَ الَّذِي",
      "start": "Al-Israa 1",
      "ayahs": 185,
    },
    {
      "id": 16,
      "name": "Qal Alam",
      "arabic": "قَالَ أَلَمْ",
      "start": "Al-Kahf 75",
      "ayahs": 269,
    },
    {
      "id": 17,
      "name": "Iqtaraba Lin Nasi",
      "arabic": "اقْتَرَبَ لِلنَّاسِ",
      "start": "Al-Anbiyaa 1",
      "ayahs": 190,
    },
    {
      "id": 18,
      "name": "Qadd Aflaha",
      "arabic": "قَدْ أَفْلَحَ",
      "start": "Al-Muminoon 1",
      "ayahs": 202,
    },
    {
      "id": 19,
      "name": "Wa Qalallazina",
      "arabic": "وَقَالَ الَّذِينَ",
      "start": "Al-Furqaan 21",
      "ayahs": 339,
    },
    {
      "id": 20,
      "name": "A'man Khalaqa",
      "arabic": "أَمَّنْ خَلَقَ",
      "start": "An-Naml 56",
      "ayahs": 171,
    },
    {
      "id": 21,
      "name": "Utlu Ma Oohiya",
      "arabic": "اتْلُ مَا أُوحِيَ",
      "start": "Al-Ankaboot 46",
      "ayahs": 178,
    },
    {
      "id": 22,
      "name": "Wa Manyaqnut",
      "arabic": "وَمَنْ يَقْنُتْ",
      "start": "Al-Ahzaab 31",
      "ayahs": 169,
    },
    {
      "id": 23,
      "name": "Wa Mali",
      "arabic": "وَمَا لِيَ",
      "start": "Yaseen 28",
      "ayahs": 357,
    },
    {
      "id": 24,
      "name": "Faman Azlam",
      "arabic": "فَمَنْ أَظْلَمُ",
      "start": "Az-Zumar 32",
      "ayahs": 175,
    },
    {
      "id": 25,
      "name": "Ilayhi Yuraddu",
      "arabic": "إِلَيْهِ يُرَدُّ",
      "start": "Fussilat 47",
      "ayahs": 246,
    },
    {
      "id": 26,
      "name": "Ha'a Meem",
      "arabic": "حم",
      "start": "Al-Ahqaf 1",
      "ayahs": 195,
    },
    {
      "id": 27,
      "name": "Qala Fama Khatbukum",
      "arabic": "قَالَ فَمَا خَطْبُكُمْ",
      "start": "Adh-Dhaariyaat 31",
      "ayahs": 399,
    },
    {
      "id": 28,
      "name": "Qadd Sami Allah",
      "arabic": "قَدْ سَمِعَ اللَّهُ",
      "start": "Al-Mujaadila 1",
      "ayahs": 137,
    },
    {
      "id": 29,
      "name": "Tabarakallazi",
      "arabic": "تَبَارَكَ الَّذِي",
      "start": "Al-Mulk 1",
      "ayahs": 431,
    },
    {
      "id": 30,
      "name": "Amma Yatasa'aloon",
      "arabic": "عَمَّ يَتَسَاءَلُونَ",
      "start": "An-Naba 1",
      "ayahs": 564,
    },
  ];

  /// Fetch all 114 Surahs
  static Future<List<Map<String, dynamic>>> getAllSurahs() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['code'] == 200 && decoded['data'] != null) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }
    }
    throw Exception('Failed to load surahs from API');
  }

  /// Fetch full surah with Arabic, Urdu, and English translations
  static Future<Map<String, dynamic>> getSurahDetail(int surahNumber) async {
    final url =
        '$_baseUrl/surah/$surahNumber/editions/quran-uthmani,ur.jalandhry,en.sahih';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['code'] == 200 && decoded['data'] is List) {
        final editions = decoded['data'] as List;
        final arabicData = editions.firstWhere(
          (e) => e['edition']['identifier'] == 'quran-uthmani',
          orElse: () => editions[0],
        );
        final urduData = editions.firstWhere(
          (e) => e['edition']['identifier'] == 'ur.jalandhry',
          orElse: () => null,
        );
        final englishData = editions.firstWhere(
          (e) => e['edition']['identifier'] == 'en.sahih',
          orElse: () => null,
        );

        final List arabicAyahs = arabicData['ayahs'] ?? [];
        final List urduAyahs = urduData != null ? urduData['ayahs'] : [];
        final List englishAyahs = englishData != null
            ? englishData['ayahs']
            : [];

        List<Map<String, dynamic>> combinedAyahs = [];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final a = arabicAyahs[i];
          final u = i < urduAyahs.length ? urduAyahs[i] : null;
          final e = i < englishAyahs.length ? englishAyahs[i] : null;

          combinedAyahs.add({
            'number': a['number'],
            'numberInSurah': a['numberInSurah'],
            'juz': a['juz'],
            'text': a['text'],
            'urdu': u != null ? u['text'] : '',
            'english': e != null ? e['text'] : '',
            'audio':
                'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${a['number']}.mp3',
          });
        }

        return {
          'number': arabicData['number'],
          'name': arabicData['name'],
          'englishName': arabicData['englishName'],
          'englishNameTranslation': arabicData['englishNameTranslation'],
          'revelationType': arabicData['revelationType'],
          'numberOfAyahs': arabicData['numberOfAyahs'],
          'ayahs': combinedAyahs,
        };
      }
    }
    throw Exception('Failed to load surah details');
  }

  /// Fetch full Juz (Para) with Arabic, Urdu, and English translations
  static Future<Map<String, dynamic>> getJuzDetail(int juzNumber) async {
    final responses = await Future.wait([
      http.get(Uri.parse('$_baseUrl/juz/$juzNumber/quran-uthmani')),
      http.get(Uri.parse('$_baseUrl/juz/$juzNumber/ur.jalandhry')),
      http.get(Uri.parse('$_baseUrl/juz/$juzNumber/en.sahih')),
    ]);

    final editionData = responses.map((response) {
      if (response.statusCode != 200) {
        throw Exception('Failed to load Juz details');
      }

      final decoded = jsonDecode(response.body);
      if (decoded['code'] != 200 || decoded['data'] is! Map) {
        throw Exception('Invalid Juz response');
      }
      return Map<String, dynamic>.from(decoded['data']);
    }).toList();

    final arabicAyahs = List<Map<String, dynamic>>.from(
      editionData[0]['ayahs'] ?? [],
    );
    final urduAyahs = {
      for (final ayah in editionData[1]['ayahs'] as List)
        ayah['number'] as int: ayah,
    };
    final englishAyahs = {
      for (final ayah in editionData[2]['ayahs'] as List)
        ayah['number'] as int: ayah,
    };

    final combinedAyahs = arabicAyahs.map((ayah) {
      final number = ayah['number'] as int;
      final surah = ayah['surah'] as Map<String, dynamic>?;
      return <String, dynamic>{
        'number': number,
        'numberInSurah': ayah['numberInSurah'],
        'surahName': surah?['englishName'] ?? '',
        'surahArabic': surah?['name'] ?? '',
        'surahNumber': surah?['number'] ?? 0,
        'juz': ayah['juz'],
        'text': ayah['text'],
        'urdu': urduAyahs[number]?['text'] ?? '',
        'english': englishAyahs[number]?['text'] ?? '',
        'audio':
            'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$number.mp3',
      };
    }).toList();

    final meta = juzList.firstWhere(
      (j) => j['id'] == juzNumber,
      orElse: () => {"id": juzNumber, "name": "Para $juzNumber", "arabic": ""},
    );

    return {
      'juzNumber': juzNumber,
      'name': meta['name'],
      'arabic': meta['arabic'],
      'ayahs': combinedAyahs,
    };
  }

  // ================= LAST READ & BOOKMARKS =================
  static const String _keyLastRead = 'quran_last_read';
  static const String _keyBookmarks = 'quran_bookmarks';

  static Future<void> saveLastRead({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyLastRead, data);
  }

  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyLastRead);
    if (str != null) {
      return jsonDecode(str) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBookmarks) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<bool> isBookmarked(int ayahGlobalNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b['number'] == ayahGlobalNumber);
  }

  static Future<void> toggleBookmark(Map<String, dynamic> ayahData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyBookmarks) ?? [];
    final existingIndex = list.indexWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['number'] == ayahData['number'];
    });

    if (existingIndex >= 0) {
      list.removeAt(existingIndex);
    } else {
      list.add(jsonEncode(ayahData));
    }
    await prefs.setStringList(_keyBookmarks, list);
  }
}
