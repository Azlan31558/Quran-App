import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =========================================================
// 1. HADITH COLLECTIONS SCREEN
// =========================================================

class HadithCollectionsScreen extends StatefulWidget {
  const HadithCollectionsScreen({super.key});

  @override
  State<HadithCollectionsScreen> createState() =>
      _HadithCollectionsScreenState();
}

class _HadithCollectionsScreenState extends State<HadithCollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Famous Hadith Collections with slugs for Ara, Urd & Eng
  final List<Map<String, dynamic>> allCollections = [
    {
      "name": "Sahih Bukhari",
      "count": "Sahih Collection",
      "icon": Icons.menu_book,
      "araSlug": "ara-bukhari",
      "urdSlug": "urd-bukhari",
      "engSlug": "eng-bukhari",
    },
    {
      "name": "Sahih Muslim",
      "count": "Sahih Collection",
      "icon": Icons.library_books,
      "araSlug": "ara-muslim",
      "urdSlug": "urd-muslim",
      "engSlug": "eng-muslim",
    },
    {
      "name": "Jami at-Tirmidhi",
      "count": "Sunan Collection",
      "icon": Icons.book,
      "araSlug": "ara-tirmidhi",
      "urdSlug": "urd-tirmidhi",
      "engSlug": "eng-tirmidhi",
    },
    {
      "name": "Sunan Abu Dawood",
      "count": "Sunan Collection",
      "icon": Icons.auto_stories,
      "araSlug": "ara-abudawud",
      "urdSlug": "urd-abudawud",
      "engSlug": "eng-abudawud",
    },
    {
      "name": "Sunan an-Nasai",
      "count": "Sunan Collection",
      "icon": Icons.chrome_reader_mode,
      "araSlug": "ara-nasai",
      "urdSlug": "urd-nasai",
      "engSlug": "eng-nasai",
    },
    {
      "name": "Sunan Ibn Majah",
      "count": "Sunan Collection",
      "icon": Icons.menu_book,
      "araSlug": "ara-ibnmajah",
      "urdSlug": "urd-ibnmajah",
      "engSlug": "eng-ibnmajah",
    },
    {
      "name": "Muwatta Malik",
      "count": "Early Collection",
      "icon": Icons.library_books,
      "araSlug": "ara-malik",
      "urdSlug": "urd-malik",
      "engSlug": "eng-malik",
    },
  ];

  List<Map<String, dynamic>> filteredCollections = [];

  @override
  void initState() {
    super.initState();
    filteredCollections = allCollections;
    _searchController.addListener(_filterCollections);
  }

  void _filterCollections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCollections = allCollections.where((item) {
        return item["name"].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Hadith Collections",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Hadith Collection...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xff0A5448),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCollections.length,
                itemBuilder: (context, index) {
                  final item = filteredCollections[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xff0A5448),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xffF4B400),
                        child: Icon(
                          item["icon"] as IconData,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        item["name"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        item["count"] as String,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HadithDetailScreen(
                              collectionName: item["name"] as String,
                              araSlug: item["araSlug"] as String,
                              urdSlug: item["urdSlug"] as String,
                              engSlug: item["engSlug"] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 2. HADITH DETAIL SCREEN (ARABIC + URDU + ENGLISH)
// =========================================================

class HadithDetailScreen extends StatefulWidget {
  final String collectionName;
  final String araSlug;
  final String urdSlug;
  final String engSlug;

  const HadithDetailScreen({
    super.key,
    required this.collectionName,
    required this.araSlug,
    required this.urdSlug,
    required this.engSlug,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  bool isLoading = true;
  String errorMessage = "";
  List<dynamic> hadithsList = [];

  @override
  void initState() {
    super.initState();
    fetchHadiths();
  }

  Future<void> fetchHadiths() async {
    try {
      final araUrl = Uri.parse(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${widget.araSlug}.json",
      );
      final urdUrl = Uri.parse(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${widget.urdSlug}.json",
      );
      final engUrl = Uri.parse(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${widget.engSlug}.json",
      );

      // Arabic, Urdu aur English teeno APIs ko parallel fetch kar rahe hain
      final responses = await Future.wait([
        http.get(araUrl),
        http.get(urdUrl),
        http.get(engUrl),
      ]);

      if (responses[0].statusCode == 200) {
        final araData = jsonDecode(responses[0].body);
        final List<dynamic> araHadiths = araData["hadiths"] ?? [];

        List<dynamic> urdHadiths = [];
        if (responses[1].statusCode == 200) {
          final urdData = jsonDecode(responses[1].body);
          urdHadiths = urdData["hadiths"] ?? [];
        }

        List<dynamic> engHadiths = [];
        if (responses[2].statusCode == 200) {
          final engData = jsonDecode(responses[2].body);
          engHadiths = engData["hadiths"] ?? [];
        }

        List<Map<String, dynamic>> combined = [];
        for (int i = 0; i < araHadiths.length; i++) {
          combined.add({
            "number": araHadiths[i]["hadithnumber"] ?? araHadiths[i]["number"] ?? (i + 1),
            "arabic": araHadiths[i]["text"] ?? "",
            "urdu": i < urdHadiths.length
                ? (urdHadiths[i]["text"] ?? "اردو ترجمہ دستیاب نہیں")
                : "اردو ترجمہ دستیاب نہیں",
            "english": i < engHadiths.length
                ? (engHadiths[i]["text"] ?? "English translation unavailable")
                : "English translation unavailable",
          });
        }

        if (!mounted) return;
        setState(() {
          hadithsList = combined;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data from server");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Error loading Hadiths. Please check your internet connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          widget.collectionName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xffF4B400),
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hadithsList.length,
                  itemBuilder: (context, index) {
                    final hadith = hadithsList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff0A5448),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xffF4B400).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Hadith #${hadith["number"]}",
                                style: const TextStyle(
                                  color: Color(0xffF4B400),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(
                                Icons.bookmark_border,
                                color: Color(0xffF4B400),
                                size: 22,
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 20),

                          // 1. ARABIC TEXT
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xff022C25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hadith["arabic"],
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Color(0xffFFD86A),
                                fontSize: 19,
                                height: 1.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 2. URDU TRANSLATION
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xff033B33),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "اردو ترجمہ",
                                  style: TextStyle(
                                    color: Color(0xffF4B400),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hadith["urdu"],
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 3. ENGLISH TRANSLATION
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ENGLISH TRANSLATION",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hadith["english"],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}