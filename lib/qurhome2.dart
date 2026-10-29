import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> surahs = [];
  List<Map<String, dynamic>> filteredSurahs = [];

  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    getsurah();
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
        _filterSurahs();
      });
    });

    // _loadQuranData();
  }

  // =========================================================
  // LOAD DATA FROM JSON
  // =========================================================
// Future<void> _loadQuranData() async {
//   setState(() {
//     surahs = [
//       {
//         "id": 1,
//         "name": "Al-Fatihah",
//         "arabic": "الفاتحة",
//         "ayahs": 7
//       },
//       {
//         "id": 2,
//         "name": "Al-Baqarah",
//         "arabic": "البقرة",
//         "ayahs": 286
//       }
//     ];

//     filteredSurahs = List.from(surahs);
//     isLoading = false;
//   });
// }
// Load data from database

Future getsurah() async{
  var res = await http.post(Uri.parse('https://devtechnical.com/AllUser/islamicquraan.php'),);
  var result = jsonDecode(res.body);
  setState(() {
    surahs=result;
  });
}
  // =========================================================
  // SEARCH
  // =========================================================

  void _filterSurahs() {
    if (searchQuery.isEmpty) {
      filteredSurahs = List.from(surahs);
      return;
    }

    filteredSurahs = surahs.where((surah) {
      final String name =
          surah['Sname'].toString().toLowerCase();

      final String arabic =
          surah['arabic'].toString();

      final String id =
          surah['id'].toString();

      return name.contains(searchQuery) ||
          arabic.contains(searchQuery) ||
          id == searchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),

        title: const Text(
          'Holy Quran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              // Future: Quran settings
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white70,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // =================================================
          // SEARCH
          // =================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: TextField(
              controller: _searchController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                hintText: 'Search Surah...',

                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white70,
                ),

                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white70,
                        ),
                      )
                    : null,

                filled: true,

                fillColor: const Color(0xff0A5448),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // =================================================
          // LAST READ
          // =================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/surahDetail',
                  arguments: 2,
                );
              },

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),

                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      Color(0xff0A5448),
                      Color(0xff0D6B5C),
                    ],
                  ),

                  border: Border.all(
                    color: const Color(0xffF4B400)
                        .withOpacity(0.20),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,

                      decoration: BoxDecoration(
                        color: const Color(0xffF4B400)
                            .withOpacity(0.15),

                        borderRadius:
                            BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xffF4B400),
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Last Read',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Surah Al-Baqarah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Ayah 255',
                            style: TextStyle(
                              color: Color(0xffF4B400),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // TABS
          // =================================================

          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16),

            decoration: BoxDecoration(
              color: const Color(0xff0A5448),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: TabBar(
              controller: _tabController,

              indicator: BoxDecoration(
                color: const Color(0xffF4B400),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              indicatorSize:
                  TabBarIndicatorSize.tab,

              labelColor: Colors.black,

              unselectedLabelColor:
                  Colors.white60,

              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),

              dividerColor: Colors.transparent,

              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Para'),
                Tab(text: 'Bookmarks'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =================================================
          // TAB VIEW
          // =================================================

          Expanded(
            child: TabBarView(
              controller: _tabController,

              children: [
                // SURAH
                isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color: Color(0xffF4B400),
                        ),
                      )
                    : filteredSurahs.isEmpty
                        ? const Center(
                            child: Text(
                              'No Surah found',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(
                              16,
                              10,
                              16,
                              20,
                            ),

                            itemCount:
                                filteredSurahs.length,

                            itemBuilder:
                                (context, index) {
                              final surah =
                                  filteredSurahs[index];

                              return _SurahCard(
                                surah: surah,

                                onTap: () {
                                  // ==================================
                                  // OPEN SELECTED SURAH DETAIL
                                  // ==================================

                                  Navigator.pushNamed(
                                    context,
                                    '/surahDetail',
                                    arguments:
                                        surah['id'],
                                  );
                                },
                              );
                            },
                          ),

                // PARA
                const ParaTab(),

                // BOOKMARK
                const BookmarkTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// SURAH CARD
// ==========================================================

class _SurahCard extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;

  const _SurahCard({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 11),

      decoration: BoxDecoration(
        color: const Color(0xff0A5448),

        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        onTap: onTap,

        // ====================================================
        // SURAH NUMBER
        // ====================================================

        leading: Container(
          height: 45,
          width: 45,

          decoration: BoxDecoration(
            color: const Color(0xffF4B400),

            borderRadius:
                BorderRadius.circular(13),
          ),

          child: Center(
            child: Text(
              surah['id'].toString(),

              style: const TextStyle(
                color: Colors.black,
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // ====================================================
        // SURAH NAME
        // ====================================================

        title: Text(
          surah['sname'].toString(),

          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // ====================================================
        // AYAH COUNT
        // ====================================================

        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 4),

          child: Text(
            '${surah['ayah']} Ayahs',

            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ),

        // ====================================================
        // ARABIC NAME
        // ====================================================

        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              surah['arabic'].toString(),

              textDirection:
                  TextDirection.rtl,

              style: const TextStyle(
                color: Color(0xffF4B400),
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white38,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PARA TAB
// ==========================================================

class ParaTab extends StatelessWidget {
  const ParaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: 30,

      itemBuilder: (context, index) {
        final paraNumber = index + 1;

        return Container(
          margin:
              const EdgeInsets.only(bottom: 11),

          decoration: BoxDecoration(
            color: const Color(0xff0A5448),

            borderRadius:
                BorderRadius.circular(16),
          ),

          child: ListTile(
            leading: Container(
              height: 45,
              width: 45,

              decoration: BoxDecoration(
                color: const Color(0xffF4B400)
                    .withOpacity(0.15),

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Center(
                child: Text(
                  '$paraNumber',

                  style: const TextStyle(
                    color:
                        Color(0xffF4B400),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            title: Text(
              'Para $paraNumber',

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: const Text(
              'Juz',

              style: TextStyle(
                color: Colors.white54,
              ),
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white38,
              size: 15,
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================
// BOOKMARK TAB
// ==========================================================

class BookmarkTab extends StatelessWidget {
  const BookmarkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.bookmark_border_rounded,
            color: Color(0xffF4B400),
            size: 55,
          ),

          SizedBox(height: 15),

          Text(
            'No Bookmarks Yet',

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Your bookmarked Ayahs will appear here.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
