import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:holyquran/allah_audio_service.dart';

class AllahNameDetailScreen extends StatefulWidget {
  const AllahNameDetailScreen({
    super.key,
    this.nameData = const <String, dynamic>{
      'number': 1,
      'name': 'ٱلرَّحْمَٰنُ',
      'transliteration': 'Ar-Rahman',
      'en': <String, dynamic>{'meaning': 'The Most Merciful'},
    },
    this.names = const [],
    this.initialIndex = 0,
  });

  final Map<String, dynamic> nameData;
  final List<Map<String, dynamic>> names;
  final int initialIndex;

  @override
  State<AllahNameDetailScreen> createState() => _AllahNameDetailScreenState();
}

class _AllahNameDetailScreenState extends State<AllahNameDetailScreen> {
  late final AudioPlayer _audioPlayer;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _hasCompleted = false;
  late int _currentIndex;
  int _playRequest = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  Map<String, dynamic> get _currentName =>
      widget.names.isEmpty ? widget.nameData : widget.names[_currentIndex];

  String get _arabicName => _currentName['name']?.toString() ?? '';
  String get _transliteration =>
      _currentName['transliteration']?.toString() ?? '';
  String get _number => _currentName['number']?.toString() ?? '1';
  String get _meaning {
    final english = _currentName['en'];
    if (english is Map) {
      return english['meaning']?.toString() ?? 'Meaning unavailable';
    }
    return 'Meaning unavailable';
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.names.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.names.length - 1);
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted && widget.names.isNotEmpty) {
        unawaited(_moveBy(1));
      } else if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasCompleted = true;
          _position = _duration;
        });
      }
    });
    unawaited(_playAudio());
  }

  Future<void> _playAudio() async {
    final request = ++_playRequest;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasCompleted = false;
      _position = Duration.zero;
    });

    try {
      await _audioPlayer.stop();
      final audioUrl = await fetchAllahNameAudioUrl(_number);
      if (!mounted || request != _playRequest) return;
      await _audioPlayer.play(UrlSource(audioUrl));
      if (mounted && request == _playRequest) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (mounted && request == _playRequest) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Audio could not be played. Check your connection.';
        });
      }
    }
  }

  Future<void> _moveBy(int offset) async {
    if (widget.names.isEmpty) return;

    setState(() {
      _currentIndex =
          (_currentIndex + offset + widget.names.length) % widget.names.length;
    });
    await _playAudio();
  }

  Future<void> _togglePlayback() async {
    if (_isLoading) return;
    if (_errorMessage != null || _hasCompleted) {
      await _playAudio();
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildTrackButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 52,
            child: IconButton(
              tooltip: label,
              onPressed: onPressed,
              icon: Icon(icon, size: 28),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                disabledForegroundColor: Colors.white38,
                shape: const CircleBorder(),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds = _duration.inSeconds > 0 ? _duration.inSeconds : 1;

    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        foregroundColor: Colors.white,
        title: Text('Name $_number of 99'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xffF4B400),
                  child: Text(
                    _number,
                    style: const TextStyle(
                      color: Color(0xff033B33),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _arabicName,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Color(0xffF4B400),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _transliteration,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _meaning,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                decoration: BoxDecoration(
                  color: const Color(0xff0A5448),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Name audio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: const Color(0xffF4B400).withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      min: 0,
                      max: maxSeconds.toDouble(),
                      value: _position.inSeconds
                          .clamp(0, maxSeconds)
                          .toDouble(),
                      activeColor: const Color(0xffF4B400),
                      inactiveColor: Colors.white24,
                      onChanged: _duration == Duration.zero
                          ? null
                          : (value) => _audioPlayer.seek(
                              Duration(seconds: value.toInt()),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _errorMessage ??
                              (_isLoading
                                  ? 'Loading audio...'
                                  : _isPlaying
                                  ? 'Playing'
                                  : 'Paused'),
                          style: TextStyle(
                            color: _errorMessage == null
                                ? Colors.white70
                                : Colors.orangeAccent,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTrackButton(
                          label: 'Previous',
                          icon: Icons.skip_previous_rounded,
                          onPressed: widget.names.isEmpty
                              ? null
                              : () => _moveBy(-1),
                        ),
                        const SizedBox(width: 14),
                        SizedBox.square(
                          dimension: 72,
                          child: IconButton(
                            tooltip: _isPlaying ? 'Pause audio' : 'Play audio',
                            onPressed: _isLoading ? null : _togglePlayback,
                            iconSize: 38,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xffF4B400),
                              foregroundColor: const Color(0xff033B33),
                              disabledBackgroundColor: const Color(
                                0xffF4B400,
                              ).withValues(alpha: 0.55),
                              shape: const CircleBorder(),
                              elevation: 4,
                              shadowColor: Colors.black38,
                            ),
                            icon: _isLoading
                                ? const SizedBox.square(
                                    dimension: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xff033B33),
                                    ),
                                  )
                                : Icon(
                                    _errorMessage != null || _hasCompleted
                                        ? Icons.replay_rounded
                                        : _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        _buildTrackButton(
                          label: 'Next',
                          icon: Icons.skip_next_rounded,
                          onPressed: widget.names.isEmpty
                              ? null
                              : () => _moveBy(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
