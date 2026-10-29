import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:holyquran/allah_audio_service.dart';
import 'package:holyquran/namedtail.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  bool isLoading = true;
  List<dynamic> names = [];

  // Audio Player State
  late AudioPlayer _audioPlayer;
  int currentPlayingIndex = -1; // -1 = nothing playing
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    getNames();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Listen to player status
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Track audio total duration
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          totalDuration = d;
        });
      }
    });

    // Track playback position
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          currentPosition = p;
        });
      }
    });

    // Auto-advance to the next name when the current one finishes
    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted || names.isEmpty) return;
      final nextIndex = (currentPlayingIndex + 1) % names.length;
      unawaited(playNameAtIndex(nextIndex));
    });
  }

  Future<void> getNames() async {
    final url = Uri.parse('https://api.aladhan.com/v1/asmaAlHusna');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          names = jsonResponse['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading names: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Play audio by index with safe Web CORS fallback
  Future<void> playNameAtIndex(int index) async {
    if (index < 0 || index >= names.length) return;

    setState(() {
      currentPlayingIndex = index;
      currentPosition = Duration.zero;
    });

    // Auto-scroll list to active item
    _scrollToIndex(index);

    final String number = names[index]['number'].toString();

    try {
      await _audioPlayer.stop();
      final audioUrl = await fetchAllahNameAudioUrl(number);
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print("Audio Playback Error: $e");

      // Gracefully handles browser CORS or connection restrictions on Flutter Web
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Audio restricted on Web browser due to CORS. Please test on an Android/iOS emulator or phone.",
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (currentPlayingIndex == -1 && names.isNotEmpty) {
      playNameAtIndex(0);
    } else if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _openName(int index) async {
    if (index < 0 || index >= names.length) return;

    await _audioPlayer.stop();
    if (!mounted) return;

    setState(() {
      currentPlayingIndex = -1;
      isPlaying = false;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
    });

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AllahNameDetailScreen(
          nameData: Map<String, dynamic>.from(names[index] as Map),
          names: names
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          initialIndex: index,
        ),
      ),
    );
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        index * 88.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _scrollController.dispose();
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          '99 Names of Allah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isLoading && names.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => playNameAtIndex(0),
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Color(0xffF4B400),
                ),
                label: const Text(
                  'Play All',
                  style: TextStyle(
                    color: Color(0xffF4B400),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffF4B400)),
            )
          : names.isEmpty
          ? const Center(
              child: Text(
                'No data found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      final item = names[index];
                      final bool isSelected = currentPlayingIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff0F7B6C)
                              : const Color(0xff0A5448),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xffF4B400),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            onTap: () => _openName(index),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.white
                                  : const Color(0xffF4B400),
                              child: Text(
                                item['number'].toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xff033B33)
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item['transliteration'].toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xffF4B400)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Text(
                              item['en']['meaning'].toString(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['name'].toString(),
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: Color(0xffF4B400),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  isSelected && isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: isSelected
                                      ? const Color(0xffF4B400)
                                      : Colors.white38,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Persistent Player Bar
                if (currentPlayingIndex != -1) _buildBottomAudioPlayerBar(),
              ],
            ),
    );
  }

  Widget _buildBottomAudioPlayerBar() {
    final currentItem = names[currentPlayingIndex];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff0A5448),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slider Progress
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: const Color(0xffF4B400),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xffF4B400),
              ),
              child: Slider(
                min: 0.0,
                max: totalDuration.inSeconds > 0
                    ? totalDuration.inSeconds.toDouble()
                    : 1.0,
                value: currentPosition.inSeconds.toDouble().clamp(
                  0.0,
                  totalDuration.inSeconds > 0
                      ? totalDuration.inSeconds.toDouble()
                      : 1.0,
                ),
                onChanged: (val) {
                  _audioPlayer.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xffF4B400),
                        child: Text(
                          currentItem['number'].toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem['transliteration'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentItem['name'].toString(),
                              style: const TextStyle(
                                color: Color(0xffF4B400),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed: () => playNameAtIndex(
                        (currentPlayingIndex - 1 + names.length) % names.length,
                      ),
                    ),
                    IconButton(
                      iconSize: 38,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: const Color(0xffF4B400),
                      ),
                      onPressed: togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: () => playNameAtIndex(
                        (currentPlayingIndex + 1) % names.length,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
