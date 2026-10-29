import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holyquran/dua_service.dart';

class DuaDetailScreen extends StatefulWidget {
  const DuaDetailScreen({
    super.key,
    this.category = const <String, dynamic>{
      'id': 27,
      'title': 'صبح و شام کے اذکار',
      'textUrl': 'https://www.hisnmuslim.com/api/en/27.json',
    },
  });

  final Map<String, dynamic> category;

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  late final AudioPlayer _audioPlayer;
  List<Map<String, dynamic>> _duas = [];
  bool _isLoading = true;
  bool _isAudioLoading = false;
  bool _isPlaying = false;
  String? _playingDuaId;
  String? _errorMessage;
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.category['title']?.toString() ?? 'Duas';
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingDuaId = null;
        });
      }
    });
    unawaited(_loadDuas());
  }

  Future<void> _loadDuas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DuaService.getCategoryDuas(
        widget.category['textUrl']?.toString() ?? '',
      );
      if (!mounted) return;
      setState(() {
        _duas = List<Map<String, dynamic>>.from(result['duas'] ?? []);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load duas. Check your connection.';
        _isLoading = false;
      });
    }
  }

  String _urduNumber(int number) {
    const digits = '۰۱۲۳۴۵۶۷۸۹';
    return number.toString().split('').map((digit) {
      final value = int.parse(digit);
      return digits[value];
    }).join();
  }

  Future<void> _toggleAudio(Map<String, dynamic> dua) async {
    final id = dua['id']?.toString();
    final audioUrl = dua['arabicAudioUrl']?.toString();
    if (id == null || audioUrl == null || audioUrl.isEmpty || _isAudioLoading) {
      return;
    }

    if (_playingDuaId == id && _isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    setState(() {
      _isAudioLoading = true;
      _playingDuaId = id;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio could not be played.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAudioLoading = false);
    }
  }

  Future<void> _copyDua(Map<String, dynamic> dua) async {
    final text = [
      dua['arabic'],
      dua['transliteration'],
      dua['translation'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join('\n\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dua copied'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        foregroundColor: Colors.white,
        title: Text(_title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xffF4B400)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xffF4B400),
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadDuas,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffF4B400),
                  foregroundColor: const Color(0xff033B33),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_duas.isEmpty) {
      return const Center(
        child: Text('No duas found', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _duas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildDuaCard(_duas[index], index),
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua, int index) {
    final id = dua['id']?.toString();
    final arabic = dua['arabic']?.toString() ?? '';
    final transliteration = dua['transliteration']?.toString() ?? '';
    final translation = dua['translation']?.toString() ?? '';
    final repeat = dua['repeat']?.toString() ?? '1';
    final audioUrl = dua['arabicAudioUrl']?.toString();
    final isPlaying = _playingDuaId == id && _isPlaying;
    final isLoadingAudio = _playingDuaId == id && _isAudioLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: const Color(0xff0A5448),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'دعا نمبر ${_urduNumber(index + 1)}',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Color(0xffF4B400),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (repeat != '1')
                Text(
                  'Repeat $repeat times',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              IconButton(
                tooltip: 'Copy dua',
                onPressed: () => _copyDua(dua),
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: Colors.white70,
              ),
              if (audioUrl != null && audioUrl.isNotEmpty && arabic.isNotEmpty)
                IconButton(
                  tooltip: isPlaying ? 'Pause Arabic dua' : 'Play Arabic dua',
                  onPressed: () => _toggleAudio(dua),
                  icon: isLoadingAudio
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xffF4B400),
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 27,
                        ),
                  color: const Color(0xffF4B400),
                ),
            ],
          ),
          if (arabic.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                height: 2,
              ),
            ),
          ],
          if (transliteration.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              transliteration,
              style: const TextStyle(
                color: Color(0xffF4B400),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          if (translation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              translation,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
