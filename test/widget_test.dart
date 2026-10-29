import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:holyquran/app_settings.dart';
import 'package:holyquran/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings screen exposes supported reading preferences', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = QuranAppSettings.instance;
    await settings.load();

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Customize your Quran experience'), findsOneWidget);
    expect(find.text('Reading Settings'), findsOneWidget);

    await tester.tap(find.text('Reading Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Arabic font size'), findsOneWidget);
    expect(find.text('Sahih International'), findsOneWidget);
    expect(find.text('Fateh Muhammad Jalandhry'), findsNothing);

    await tester.tap(find.text('Sahih International'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fateh Muhammad Jalandhry').last);
    await tester.pumpAndSettle();
    expect(settings.translation, 'ur.jalandhry');
    expect(settings.language, 'Urdu');

    await tester.scrollUntilVisible(
      find.text('Audio Settings'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1.25x'));
    await tester.pumpAndSettle();
    expect(settings.audioSpeed, 1.25);

    await settings.setTheme('dark');
    expect(settings.themeMode, ThemeMode.dark);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('quran_bookmarks', 'saved-bookmark');
    await preferences.setString('quran_last_read', 'saved-reading-position');
    await settings.reset();

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.audioSpeed, QuranAppSettings.defaultAudioSpeed);
    expect(settings.reminderEnabled, isFalse);
    expect(preferences.getString('quran_bookmarks'), 'saved-bookmark');
    expect(preferences.getString('quran_last_read'), 'saved-reading-position');
  });
}
