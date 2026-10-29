import 'package:flutter/material.dart';
import 'package:holyquran/app_settings.dart';
import 'package:holyquran/allahname.dart';
import 'package:holyquran/duacategry.dart';
import 'package:holyquran/duadetil.dart';
import 'package:holyquran/favtite.dart';
import 'package:holyquran/hadithscrn.dart';
import 'package:holyquran/home.dart';
import 'package:holyquran/islamicqalendr.dart';
import 'package:holyquran/locatio.dart';
import 'package:holyquran/mosquefinf.dart';
import 'package:holyquran/namedtail.dart';
import 'package:holyquran/notifcprmsn.dart';
import 'package:holyquran/onbunding.dart';
import 'package:holyquran/prayertime.dart';
import 'package:holyquran/profile.dart';
import 'package:holyquran/qibla.dart';
import 'package:holyquran/quran_reader_screen.dart';
import 'package:holyquran/quranaudio.dart';
import 'package:holyquran/quranscrn.dart';
import 'package:holyquran/splashscrn.dart';
import 'package:holyquran/surahdetail.dart';
import 'package:holyquran/tasbeh.dart';
import 'package:holyquran/zakat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranAppSettings.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settings = QuranAppSettings.instance;
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Holy Quran',
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        initialRoute: '/',
        routes: {
          "/": (context) => const SplashScreen(),
          "/onboarding": (context) => const OnboardingScreen(),
          "/location": (context) => const LocationPermissionScreen(),
          "/notification": (context) => const NotificationPermissionScreen(),
          "/home": (context) => const HomeScreen(),
          "/quran": (context) => const Quranscrn(),
          "/quranReader": (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map<String, dynamic>) {
              return QuranReaderScreen(
                isJuz: args['isJuz'] ?? false,
                id: args['id'] ?? 1,
                title: args['title'] ?? 'Surah',
                arabicTitle: args['arabicTitle'] ?? '',
                subtitle: args['subtitle'] ?? '',
              );
            }
            return const QuranReaderScreen(
              isJuz: false,
              id: 1,
              title: 'Al-Faatiha',
              arabicTitle: 'الفاتحة',
            );
          },

          '/surahDetail': (context) {
            final surahId = ModalRoute.of(context)!.settings.arguments as int;

            return SurahDetailScreen(
              surahId: surahId,
              name: '',
              ayah: '',
              arabic: '',
            );
          },

          "/audioPlayer": (context) => const SurahListScreen(),
          "/tasbeeh": (context) => const TasbeehScreen(),
          "/qibla": (context) => const QiblaScreen(),
          "/dua": (context) => const DuaCategoriesScreen(),
          "/duaDetail": (context) => const DuaDetailScreen(),
          "/hadith": (context) => const HadithCollectionsScreen(),

          "/hadithDetail": (context) => const HadithCollectionsScreen(),
          "/profile": (context) => const ProfileScreen(),
          "/prayer": (context) => const PrayerTimesScreen(),
          "/mosques": (context) => const MosqueFinderScreen(),
          "/calendar": (context) => const IslamicCalendarScreen(),
          "/zakat": (context) => const ZakatCalculatorScreen(),
          "/allahNames": (context) => const AllahNamesScreen(),

          "/allahNameDetail": (context) => const AllahNameDetailScreen(),
          "/favorites": (context) => const FavoritesScreen(),
          "/login": (context) => const QuranAudioPlayerScreen(),
          // home: Quranscrn(),
          //
        },
        themeMode: settings.themeMode,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF075E50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF36C9A0),
            brightness: Brightness.dark,
            surface: const Color(0xFF033B33),
          ),
          scaffoldBackgroundColor: const Color(0xFF033B33),
          useMaterial3: true,
        ),
      ),
    );
  }
}

// Add in tasbeh scren
//  CREATE TABLE tasbeeh_history(
//  id INT AUTO_INCREMENT PRIMARY KEY,
//  user_id INT,
//  total_count INT,
//  goal_count INT,
//  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
// );

// Mosque finder
// Google Places API
// // Google Maps SDK
// // Geolocator
