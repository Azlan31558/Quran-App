import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:holyquran/app_settings.dart';
import 'package:holyquran/quran_service.dart';

class QuranReaderScreen extends StatefulWidget {
  final bool isJuz;
  final int id; // Surah number (1-114) or Juz number (1-30)
  final String title;
  final String arabicTitle;
  final String subtitle;

  const QuranReaderScreen({
    super.key,
    required this.isJuz,
    required this.id,
    required this.title,
    required this.arabicTitle,
    this.subtitle = '',
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _ayahs = [];

  double _arabicFontSize = 26;
  bool _showUrdu = true;
  bool _showEnglish = true;

  int? _playingAyahNumber;
  bool _isPlaying = false;
  Set<int> _bookmarkedAyahNumbers = {};
  final QuranAppSettings _settings = QuranAppSettings.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_applyReaderSettings);
    _settings.load().then((_) => _applyReaderSettings());
    _loadData();
    _initAudio();
  }

  void _applyReaderSettings() {
    if (!mounted) return;
    setState(() {
      _arabicFontSize = _settings.arabicFontSize;
      _showUrdu =
          _settings.pageStyle == 'Translation view' &&
          _settings.translation == 'ur.jalandhry';
      _showEnglish =
          _settings.pageStyle == 'Translation view' &&
          _settings.translation == 'en.sahih';
    });
  }

  void _initAudio() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _playNextAyah();
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  void _playNextAyah() {
    if (_playingAyahNumber == null) return;
    final currentIndex = _ayahs.indexWhere(
      (a) => a['number'] == _playingAyahNumber,
    );
    if (_settings.repeatAyah && currentIndex != -1) {
      final currentAyah = _ayahs[currentIndex];
      _restartAudio(currentAyah['audio'], currentAyah['number']);
      return;
    }
    if (!_settings.autoNextAyah) {
      setState(() {
        _playingAyahNumber = null;
        _isPlaying = false;
      });
      return;
    }
    if (currentIndex != -1 && currentIndex + 1 < _ayahs.length) {
      final nextAyah = _ayahs[currentIndex + 1];
      _playAudio(nextAyah['audio'], nextAyah['number']);
    } else {
      setState(() {
        _playingAyahNumber = null;
        _isPlaying = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isJuz) {
        final data = await QuranService.getJuzDetail(widget.id);
        _ayahs = List<Map<String, dynamic>>.from(data['ayahs'] ?? []);
      } else {
        final data = await QuranService.getSurahDetail(widget.id);
        _ayahs = List<Map<String, dynamic>>.from(data['ayahs'] ?? []);
      }

      // Load bookmarks
      final bookmarks = await QuranService.getBookmarks();
      _bookmarkedAyahNumbers = bookmarks.map((b) => b['number'] as int).toSet();

      // Save Last Read
      if (!widget.isJuz && _ayahs.isNotEmpty) {
        QuranService.saveLastRead(
          surahNumber: widget.id,
          surahName: widget.title,
          ayahNumber: 1,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAudio(String url, int ayahNumber) async {
    try {
      if (_playingAyahNumber == ayahNumber && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _restartAudio(url, ayahNumber);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Audio play error: $e')));
      }
    }
  }

  Future<void> _restartAudio(String url, int ayahNumber) async {
    await _audioPlayer.stop();
    await _audioPlayer.setPlaybackRate(_settings.audioSpeed);
    if (mounted) {
      setState(() {
        _playingAyahNumber = ayahNumber;
      });
    }
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> _toggleBookmark(Map<String, dynamic> ayah) async {
    await QuranService.toggleBookmark({
      ...ayah,
      'surahName': widget.title,
      'surahId': widget.id,
      'isJuz': widget.isJuz,
    });
    final bookmarks = await QuranService.getBookmarks();
    if (!mounted) return;
    setState(() {
      _bookmarkedAyahNumbers = bookmarks.map((b) => b['number'] as int).toSet();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          _bookmarkedAyahNumbers.contains(ayah['number'])
              ? 'Ayah Bookmarked!'
              : 'Bookmark Removed',
        ),
      ),
    );
  }

  void _copyAyah(Map<String, dynamic> ayah) {
    final text =
        "${ayah['text']}\n\nUrdu: ${ayah['urdu']}\n\nEnglish: ${ayah['english']}\n[${widget.title} - Ayah ${ayah['numberInSurah']}]";
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Ayah copied to clipboard'),
      ),
    );
  }

  @override
  void dispose() {
    _settings.removeListener(_applyReaderSettings);
    _audioPlayer.dispose();
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
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Text Settings',
            icon: const Icon(Icons.tune),
            onPressed: () => _showSettingsSheet(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              "Loading Holy Quran...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.amber, size: 50),
              const SizedBox(height: 12),
              Text(
                "Unable to load: $_errorMessage",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header Banner
        _buildHeaderCard(),

        // Ayahs List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: _ayahs.length,
            separatorBuilder: (context, i) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final ayah = _ayahs[index];
              final isCurrentPlaying =
                  _playingAyahNumber == ayah['number'] && _isPlaying;
              final isBookmarked = _bookmarkedAyahNumbers.contains(
                ayah['number'],
              );

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isCurrentPlaying
                      ? const Color(0xff0A5E51)
                      : const Color(0xff054C41),
                  border: isCurrentPlaying
                      ? Border.all(color: Colors.amber, width: 1.5)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar inside Ayah Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.amber,
                          child: Text(
                            "${ayah['numberInSurah']}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.isJuz && ayah['surahName'] != null)
                          Text(
                            "${ayah['surahName']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isCurrentPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.amber,
                                size: 26,
                              ),
                              onPressed: () =>
                                  _playAudio(ayah['audio'], ayah['number']),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? Colors.amber
                                    : Colors.white70,
                                size: 22,
                              ),
                              onPressed: () => _toggleBookmark(ayah),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () => _copyAyah(ayah),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),

                    // Arabic Ayah
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        ayah['text'] ?? '',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: _arabicFontSize,
                          color: Color(_settings.textColor),
                          fontFamily: _settings.arabicFont == 'Serif'
                              ? 'serif'
                              : null,
                          height: 2.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Urdu Translation
                    if (_showUrdu && (ayah['urdu'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        ayah['urdu'],
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xffF2C94C),
                          height: 1.6,
                        ),
                      ),
                    ],

                    // English Translation
                    if (_showEnglish && (ayah['english'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        ayah['english'],
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0D6B5C), Color(0xff0A5448)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.subtitle.isNotEmpty)
                  Text(
                    widget.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                const SizedBox(height: 6),
                Text(
                  "${_ayahs.length} Ayahs",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            widget.arabicTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff033B33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Display & Reading Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Arabic Font Size",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "${_arabicFontSize.toInt()} pt",
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
                  Slider(
                    value: _arabicFontSize,
                    min: 18,
                    max: 40,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setModalState(() => _arabicFontSize = v);
                      setState(() => _arabicFontSize = v);
                      _persistArabicFontSize(v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Show selected translation",
                      style: TextStyle(color: Colors.white),
                    ),
                    activeThumbColor: Colors.amber,
                    value: _settings.pageStyle == 'Translation view',
                    onChanged: (val) {
                      final style = val ? 'Translation view' : 'Simple';
                      setModalState(() {});
                      _settings.setPageStyle(style);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _persistArabicFontSize(double value) async {
    try {
      await _settings.setArabicFontSize(value);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save font size: $error')),
      );
    }
  }
}
