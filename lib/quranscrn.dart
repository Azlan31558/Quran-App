import 'package:flutter/material.dart';
import 'package:holyquran/quran_reader_screen.dart';
import 'package:holyquran/quran_service.dart';

class Quranscrn extends StatefulWidget {
  const Quranscrn({super.key});

  @override
  State<Quranscrn> createState() => _QuranscrnState();
}

class _QuranscrnState extends State<Quranscrn>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _filteredSurahs = [];
  final List<Map<String, dynamic>> _allParas = QuranService.juzList;
  List<Map<String, dynamic>> _filteredParas = [];
  List<Map<String, dynamic>> _bookmarks = [];

  Map<String, dynamic>? _lastRead;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredParas = List.from(_allParas);
    _loadSurahs();
    _loadLastReadAndBookmarks();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = List.from(_allSurahs);
        _filteredParas = List.from(_allParas);
      } else {
        _filteredSurahs = _allSurahs.where((s) {
          final name = (s['englishName'] ?? '').toString().toLowerCase();
          final arabic = (s['name'] ?? '').toString();
          final translation = (s['englishNameTranslation'] ?? '')
              .toString()
              .toLowerCase();
          final number = s['number'].toString();
          return name.contains(query) ||
              arabic.contains(query) ||
              translation.contains(query) ||
              number == query;
        }).toList();

        _filteredParas = _allParas.where((p) {
          final name = (p['name'] ?? '').toString().toLowerCase();
          final id = p['id'].toString();
          return name.contains(query) || id == query;
        }).toList();
      }
    });
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final surahs = await QuranService.getAllSurahs();
      setState(() {
        _allSurahs = surahs;
        _filteredSurahs = surahs;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLastReadAndBookmarks() async {
    final lastRead = await QuranService.getLastRead();
    final bookmarks = await QuranService.getBookmarks();
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
        _bookmarks = bookmarks;
      });
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff033B33),
        elevation: 0,
        title: const Text(
          "Holy Quran",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadSurahs();
              _loadLastReadAndBookmarks();
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xff076153),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          hintText: 'Search Surah or Para...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Read Card
                    _buildLastReadCard(),
                    const SizedBox(height: 14),

                    // Tabs (Surah, Para, Bookmarks)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xff054C41),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.amber,
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: "Surah"),
                          Tab(text: "Para (Juz)"),
                          Tab(text: "Bookmarks"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildSurahTab(), _buildParaTab(), _buildBookmarksTab()],
        ),
      ),
    );
  }

  Widget _buildLastReadCard() {
    final surahName = _lastRead?['surahName'] ?? 'Al-Baqarah';
    final surahNumber = _lastRead?['surahNumber'] ?? 2;
    final ayahNumber = _lastRead?['ayahNumber'] ?? 1;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuranReaderScreen(
              isJuz: false,
              id: surahNumber,
              title: surahName,
              arabicTitle: '',
              subtitle: 'Last Read',
            ),
          ),
        );
        _loadLastReadAndBookmarks();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xff0D7061), Color(0xff084D42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Last Read',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  surahName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Surah #$surahNumber • Ayah $ayahNumber",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ================= 1. SURAH LIST TAB =================
  Widget _buildSurahTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.amber, size: 40),
            const SizedBox(height: 8),
            const Text(
              "Failed to load Surahs from API",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: _loadSurahs,
              child: const Text("Retry", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        final number = surah['number'];
        final englishName = surah['englishName'] ?? '';
        final arabicName = surah['name'] ?? '';
        final revelation = surah['revelationType'] ?? '';
        final verses = surah['numberOfAyahs'] ?? 0;
        final meaning = surah['englishNameTranslation'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xff055C4F),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    "$number",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              title: Text(
                englishName,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "$revelation • $verses Verses\n$meaning",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              trailing: Text(
                arabicName,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.amber,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranReaderScreen(
                      isJuz: false,
                      id: number,
                      title: englishName,
                      arabicTitle: arabicName,
                      subtitle: "$revelation • $verses Verses",
                    ),
                  ),
                );
                _loadLastReadAndBookmarks();
              },
            ),
          ),
        );
      },
    );
  }

  // ================= 2. PARA (JUZ) LIST TAB =================
  Widget _buildParaTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredParas.length,
      itemBuilder: (context, index) {
        final para = _filteredParas[index];
        final id = para['id'];
        final name = para['name'];
        final arabic = para['arabic'];
        final ayahs = para['ayahs'];
        final start = para['start'];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xff055C4F),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    "$id",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              title: Text(
                "Para $id: $name",
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Starts: $start\n$ayahs Ayahs",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              trailing: Text(
                arabic,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.amber,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranReaderScreen(
                      isJuz: true,
                      id: id,
                      title: "Para $id - $name",
                      arabicTitle: arabic,
                      subtitle: "$ayahs Ayahs",
                    ),
                  ),
                );
                _loadLastReadAndBookmarks();
              },
            ),
          ),
        );
      },
    );
  }

  // ================= 3. BOOKMARKS TAB =================
  Widget _buildBookmarksTab() {
    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark_border, color: Colors.white38, size: 54),
            SizedBox(height: 12),
            Text(
              "No bookmarks saved yet",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              "Tap the bookmark icon on any ayah to save it here",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final b = _bookmarks[index];
        final surahName = b['surahName'] ?? 'Surah';
        final ayahNum = b['numberInSurah'] ?? 0;
        final arabicText = b['text'] ?? '';
        final urduText = b['urdu'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xff055C4F),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$surahName : Ayah $ayahNum",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () async {
                      await QuranService.toggleBookmark(b);
                      _loadLastReadAndBookmarks();
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              Text(
                arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'serif',
                ),
              ),
              if (urduText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  urduText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
