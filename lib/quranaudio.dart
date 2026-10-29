import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:holyquran/app_settings.dart';

// Surah Data Model
class Surah {
  final int id;
  final String name;
  final String englishName;

  Surah({required this.id, required this.name, required this.englishName});

  String get audioUrl {
    // Format ID to 3 digits (e.g., 1 -> 001, 114 -> 114)
    String formattedId = id.toString().padLeft(3, '0');
    return "https://server8.mp3quran.net/afs/$formattedId.mp3";
  }
}

// Complete 114 Surahs List
final List<Surah> surahList = [
  Surah(id: 1, name: "الفاتحة", englishName: "Al-Fatihah"),
  Surah(id: 2, name: "البقرة", englishName: "Al-Baqarah"),
  Surah(id: 3, name: "آل عمران", englishName: "Ali 'Imran"),
  Surah(id: 4, name: "النساء", englishName: "An-Nisa"),
  Surah(id: 5, name: "المائدة", englishName: "Al-Ma'idah"),
  Surah(id: 6, name: "الأنعام", englishName: "Al-An'am"),
  Surah(id: 7, name: "الأعراف", englishName: "Al-A'raf"),
  Surah(id: 8, name: "الأنفال", englishName: "Al-Anfal"),
  Surah(id: 9, name: "التوبة", englishName: "At-Tawbah"),
  Surah(id: 10, name: "يونس", englishName: "Yunus"),
  Surah(id: 11, name: "هود", englishName: "Hud"),
  Surah(id: 12, name: "يوسف", englishName: "Yusuf"),
  Surah(id: 13, name: "الرعد", englishName: "Ar-Ra'd"),
  Surah(id: 14, name: "إبراهيم", englishName: "Ibrahim"),
  Surah(id: 15, name: "الحجر", englishName: "Al-Hijr"),
  Surah(id: 16, name: "النحل", englishName: "An-Nahl"),
  Surah(id: 17, name: "الإسراء", englishName: "Al-Isra"),
  Surah(id: 18, name: "الكهف", englishName: "Al-Kahf"),
  Surah(id: 19, name: "مريم", englishName: "Maryam"),
  Surah(id: 20, name: "طه", englishName: "Taha"),
  Surah(id: 21, name: "الأنبياء", englishName: "Al-Anbiya"),
  Surah(id: 22, name: "الحج", englishName: "Al-Hajj"),
  Surah(id: 23, name: "المؤمنون", englishName: "Al-Mu'minun"),
  Surah(id: 24, name: "النور", englishName: "An-Nur"),
  Surah(id: 25, name: "الفرقان", englishName: "Al-Furqan"),
  Surah(id: 26, name: "الشعراء", englishName: "Ash-Shu'ara"),
  Surah(id: 27, name: "النمل", englishName: "An-Naml"),
  Surah(id: 28, name: "القصص", englishName: "Al-Qasas"),
  Surah(id: 29, name: "العنكبوت", englishName: "Al-'Ankabut"),
  Surah(id: 30, name: "الروم", englishName: "Ar-Rum"),
  Surah(id: 31, name: "لقمان", englishName: "Luqman"),
  Surah(id: 32, name: "السجدة", englishName: "As-Sajdah"),
  Surah(id: 33, name: "الأحزاب", englishName: "Al-Ahzab"),
  Surah(id: 34, name: "سبأ", englishName: "Saba"),
  Surah(id: 35, name: "فاطر", englishName: "Fatir"),
  Surah(id: 36, name: "يس", englishName: "Ya-Sin"),
  Surah(id: 37, name: "الصافات", englishName: "As-Saffat"),
  Surah(id: 38, name: "ص", englishName: "Sad"),
  Surah(id: 39, name: "الزمر", englishName: "Az-Zumar"),
  Surah(id: 40, name: "غافر", englishName: "Ghafir"),
  Surah(id: 41, name: "فصلت", englishName: "Fussilat"),
  Surah(id: 42, name: "الشورى", englishName: "Ash-Shura"),
  Surah(id: 43, name: "الزخرف", englishName: "Az-Zukhruf"),
  Surah(id: 44, name: "الدخان", englishName: "Ad-Dukhan"),
  Surah(id: 45, name: "الجاثية", englishName: "Al-Jathiyah"),
  Surah(id: 46, name: "الأحقاف", englishName: "Al-Ahqaf"),
  Surah(id: 47, name: "محمد", englishName: "Muhammad"),
  Surah(id: 48, name: "الفتح", englishName: "Al-Fath"),
  Surah(id: 49, name: "الحجرات", englishName: "Al-Hujurat"),
  Surah(id: 50, name: "ق", englishName: "Qaf"),
  Surah(id: 51, name: "الذاريات", englishName: "Adh-Dhariyat"),
  Surah(id: 52, name: "الطور", englishName: "At-Tur"),
  Surah(id: 53, name: "النجم", englishName: "An-Najm"),
  Surah(id: 54, name: "القمر", englishName: "Al-Qamar"),
  Surah(id: 55, name: "الرحمن", englishName: "Ar-Rahman"),
  Surah(id: 56, name: "الواقعة", englishName: "Al-Waqi'ah"),
  Surah(id: 57, name: "الحديد", englishName: "Al-Hadid"),
  Surah(id: 58, name: "المجادلة", englishName: "Al-Mujadila"),
  Surah(id: 59, name: "الحشر", englishName: "Al-Hashr"),
  Surah(id: 60, name: "الممتحنة", englishName: "Al-Mumtahanah"),
  Surah(id: 61, name: "الصف", englishName: "As-Saff"),
  Surah(id: 62, name: "الجمعة", englishName: "Al-Jumu'ah"),
  Surah(id: 63, name: "المنافقون", englishName: "Al-Munafiqun"),
  Surah(id: 64, name: "التغابن", englishName: "At-Taghabun"),
  Surah(id: 65, name: "الطلاق", englishName: "At-Talaq"),
  Surah(id: 66, name: "التحريم", englishName: "At-Tahrim"),
  Surah(id: 67, name: "الملك", englishName: "Al-Mulk"),
  Surah(id: 68, name: "القلم", englishName: "Al-Qalam"),
  Surah(id: 69, name: "الحاقة", englishName: "Al-Haqqah"),
  Surah(id: 70, name: "المعارج", englishName: "Al-Ma'arij"),
  Surah(id: 71, name: "نوح", englishName: "Nuh"),
  Surah(id: 72, name: "الجن", englishName: "Al-Jinn"),
  Surah(id: 73, name: "المزمل", englishName: "Al-Muzzammil"),
  Surah(id: 74, name: "المدثر", englishName: "Al-Muddaththir"),
  Surah(id: 75, name: "القيامة", englishName: "Al-Qiyamah"),
  Surah(id: 76, name: "الإنسان", englishName: "Al-Insan"),
  Surah(id: 77, name: "المرسلات", englishName: "Al-Mursalat"),
  Surah(id: 78, name: "النبأ", englishName: "An-Naba"),
  Surah(id: 79, name: "النازعات", englishName: "An-Nazi'at"),
  Surah(id: 80, name: "عبس", englishName: "'Abasa"),
  Surah(id: 81, name: "التكوير", englishName: "At-Takwir"),
  Surah(id: 82, name: "الانفطار", englishName: "Al-Infitar"),
  Surah(id: 83, name: "المطففين", englishName: "Al-Mutaffifin"),
  Surah(id: 84, name: "الانشقاق", englishName: "Al-Inshiqaq"),
  Surah(id: 85, name: "البروج", englishName: "Al-Buruj"),
  Surah(id: 86, name: "الطارق", englishName: "At-Tariq"),
  Surah(id: 87, name: "الأعلى", englishName: "Al-A'la"),
  Surah(id: 88, name: "الغاشية", englishName: "Al-Ghashiyah"),
  Surah(id: 89, name: "الفجر", englishName: "Al-Fajr"),
  Surah(id: 90, name: "البلد", englishName: "Al-Balad"),
  Surah(id: 91, name: "الشمس", englishName: "Ash-Shams"),
  Surah(id: 92, name: "الليل", englishName: "Al-Layl"),
  Surah(id: 93, name: "الضحى", englishName: "Ad-Duha"),
  Surah(id: 94, name: "الشرح", englishName: "Ash-Sharh"),
  Surah(id: 95, name: "التين", englishName: "At-Tin"),
  Surah(id: 96, name: "العلق", englishName: "Al-'Alaq"),
  Surah(id: 97, name: "القدر", englishName: "Al-Qadr"),
  Surah(id: 98, name: "البينة", englishName: "Al-Bayyinah"),
  Surah(id: 99, name: "الزلزلة", englishName: "Az-Zalzalah"),
  Surah(id: 100, name: "العاديات", englishName: "Al-'Adiyat"),
  Surah(id: 101, name: "القارعة", englishName: "Al-Qari'ah"),
  Surah(id: 102, name: "التكاثر", englishName: "At-Takathur"),
  Surah(id: 103, name: "العصر", englishName: "Al-'Asr"),
  Surah(id: 104, name: "الهمزة", englishName: "Al-Humazah"),
  Surah(id: 105, name: "الفيل", englishName: "Al-Fil"),
  Surah(id: 106, name: "قريش", englishName: "Quraysh"),
  Surah(id: 107, name: "الماعون", englishName: "Al-Ma'un"),
  Surah(id: 108, name: "الكوثر", englishName: "Al-Kawthar"),
  Surah(id: 109, name: "الكافرون", englishName: "Al-Kafirun"),
  Surah(id: 110, name: "النصر", englishName: "An-Nasr"),
  Surah(id: 111, name: "المسد", englishName: "Al-Masad"),
  Surah(id: 112, name: "الإخلاص", englishName: "Al-Ikhlas"),
  Surah(id: 113, name: "الفلق", englishName: "Al-Falaq"),
  Surah(id: 114, name: "الناس", englishName: "An-Nas"),
];

// 1. SURAH LIST SCREEN (Main Screen)
class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        elevation: 0,
        title: const Text(
          "Quran Surahs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: surahList.length,
        itemBuilder: (context, index) {
          final surah = surahList[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xff0A5448),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xffF4B400),
                child: Text(
                  "${surah.id}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                surah.englishName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text(
                "Mishary Rashid Alafasy",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              trailing: Text(
                surah.name,
                style: const TextStyle(
                  color: Color(0xffF4B400),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuranAudioPlayerScreen(initialIndex: index),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// 2. AUDIO PLAYER SCREEN
class QuranAudioPlayerScreen extends StatefulWidget {
  final int initialIndex;

  const QuranAudioPlayerScreen({super.key, this.initialIndex = 0});

  @override
  State<QuranAudioPlayerScreen> createState() => _QuranAudioPlayerScreenState();
}

class _QuranAudioPlayerScreenState extends State<QuranAudioPlayerScreen> {
  final AudioPlayer player = AudioPlayer();
  final QuranAppSettings _settings = QuranAppSettings.instance;

  late int currentIndex;
  bool isPlaying = false;
  double? _appliedPlaybackRate;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _settings.addListener(_onSettingsChanged);

    player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    player.onPlayerComplete.listen((event) {
      if (_settings.repeatAyah) {
        playAudio();
      } else {
        playNext();
      }
    });

    _settings.load().then((_) {
      if (mounted) playAudio();
    });
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
    final speed = _settings.audioSpeed;
    if (isPlaying && _appliedPlaybackRate != speed) {
      _updatePlaybackRate(speed);
    }
  }

  Future<void> _updatePlaybackRate(double speed) async {
    try {
      await player.setPlaybackRate(speed);
      _appliedPlaybackRate = speed;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update playback speed: $error')),
      );
    }
  }

  Future<void> playAudio() async {
    try {
      await player.stop();
      await player.setPlaybackRate(_settings.audioSpeed);
      _appliedPlaybackRate = _settings.audioSpeed;
      await player.play(UrlSource(surahList[currentIndex].audioUrl));
      if (mounted) setState(() => isPlaying = true);
    } catch (error) {
      if (!mounted) return;
      setState(() => isPlaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio play error: $error')));
    }
  }

  Future<void> pauseAudio() async {
    await player.pause();

    setState(() {
      isPlaying = false;
    });
  }

  void playNext() {
    if (currentIndex < surahList.length - 1) {
      setState(() {
        currentIndex++;
        position = Duration.zero;
        duration = Duration.zero;
      });
      playAudio();
    } else if (mounted) {
      setState(() => isPlaying = false);
    }
  }

  void playPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        position = Duration.zero;
        duration = Duration.zero;
      });
      playAudio();
    }
  }

  String formatTime(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSurah = surahList[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text("Now Playing", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                  color: const Color(0xff0A5448),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSurah.name,
                      style: const TextStyle(
                        color: Color(0xffF4B400),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Icon(
                      Icons.audiotrack_outlined,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Surah ${currentSurah.englishName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Mishary Rashid Alafasy",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 30),

              Slider(
                activeColor: const Color(0xffF4B400),
                inactiveColor: Colors.white24,
                value: position.inSeconds.toDouble().clamp(
                  0.0,
                  duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
                ),
                max: duration.inSeconds > 0
                    ? duration.inSeconds.toDouble()
                    : 1.0,
                onChanged: (value) async {
                  await player.seek(Duration(seconds: value.toInt()));
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      formatTime(duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentIndex > 0 ? playPrevious : null,
                    icon: Icon(
                      Icons.skip_previous,
                      size: 40,
                      color: currentIndex > 0 ? Colors.white : Colors.white24,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffF4B400),
                    ),
                    child: IconButton(
                      iconSize: 45,
                      onPressed: () {
                        if (isPlaying) {
                          pauseAudio();
                        } else {
                          playAudio();
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  IconButton(
                    onPressed: currentIndex < surahList.length - 1
                        ? playNext
                        : null,
                    icon: Icon(
                      Icons.skip_next,
                      size: 40,
                      color: currentIndex < surahList.length - 1
                          ? Colors.white
                          : Colors.white24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _speedSelector(),
                  _actionButton(Icons.download, "Download"),
                  _actionButton(Icons.share, "Share"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xff0A5448),
          child: Icon(icon, color: const Color(0xffF4B400)),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _speedSelector() {
    return Column(
      children: [
        PopupMenuButton<double>(
          tooltip: 'Playback speed',
          initialValue: _settings.audioSpeed,
          onSelected: (speed) async {
            try {
              await _settings.setAudioSpeed(speed);
            } catch (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not save playback speed: $error'),
                ),
              );
            }
          },
          itemBuilder: (context) => const [0.5, 0.75, 1.0, 1.25, 1.5]
              .map(
                (speed) =>
                    PopupMenuItem(value: speed, child: Text('${speed}x')),
              )
              .toList(),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xff0A5448),
            child: Icon(Icons.speed, color: const Color(0xffF4B400)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_settings.audioSpeed}x',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
