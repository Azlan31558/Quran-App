import 'package:flutter/material.dart';
import 'package:holyquran/app_settings.dart';
import 'package:holyquran/reminder_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _background = Color(0xFF033B33);
  static const _emerald = Color(0xFF075E50);
  static const _accent = Color(0xFF36C9A0);
  static const _card = Color(0xFF104A40);
  static const _secondaryText = Color(0xFFB7D1CA);
  static const _gold = Color(0xFFD9B76E);
  static const _arabicPreview = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  final QuranAppSettings _settings = QuranAppSettings.instance;
  bool _isUpdatingReminder = false;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    _settings.load();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _runSetting(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save setting: $error')));
    }
  }

  Future<void> _selectOption({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...options.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selected == option
                      ? const Icon(Icons.check_circle, color: _accent)
                      : const Icon(
                          Icons.circle_outlined,
                          color: _secondaryText,
                        ),
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) onSelected(value);
  }

  Future<void> _setReminder(bool enabled) async {
    setState(() => _isUpdatingReminder = true);
    try {
      if (enabled) {
        final permission = await Permission.notification.request();
        if (!permission.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Notification permission was not granted. You can enable it in system settings.',
                ),
              ),
            );
          }
          return;
        }
        await ReminderNotifications.scheduleDaily(_settings.reminderMinute);
        await _settings.setReminderEnabled(true);
      } else {
        await ReminderNotifications.cancel();
        await _settings.setReminderEnabled(false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update daily reminder: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingReminder = false);
    }
  }

  Future<void> _chooseReminderTime() async {
    final initial = TimeOfDay(
      hour: _settings.reminderMinute ~/ 60,
      minute: _settings.reminderMinute % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final minute = picked.hour * 60 + picked.minute;
    await _runSetting(() async {
      if (_settings.reminderEnabled) {
        await ReminderNotifications.scheduleDaily(minute);
      }
      await _settings.setReminderMinute(minute);
    });
  }

  Future<void> _showPrivacy() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        icon: const Icon(Icons.privacy_tip_outlined, color: _gold),
        title: const Text(
          'Your privacy',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Reading preferences, bookmarks, and your last-read position are stored locally on this device using app preferences. Quran text and recitation audio are requested from the Quran data and audio services when needed; those network services receive the request and your network address. This screen does not create an account or send your saved bookmarks or reading history.',
          style: TextStyle(color: _secondaryText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        icon: const Icon(Icons.restart_alt_rounded, color: _gold),
        title: const Text(
          'Reset settings?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Reading, audio, appearance, and reminder settings will return to their defaults. Your bookmarks, reading history, Quran data, and account data will not be deleted.',
          style: TextStyle(color: _secondaryText, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _secondaryText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _accent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset settings'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _runSetting(() async {
      await ReminderNotifications.cancel();
      await _settings.reset();
    });
  }

  String _reminderTimeLabel() {
    final time = TimeOfDay(
      hour: _settings.reminderMinute ~/ 60,
      minute: _settings.reminderMinute % 60,
    );
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(context),
                      const SizedBox(height: 22),
                      _buildSection(
                        icon: Icons.menu_book_rounded,
                        title: 'Reading Settings',
                        subtitle: 'Make every page feel right',
                        children: _readingSettings(),
                      ),
                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.graphic_eq_rounded,
                        title: 'Audio Settings',
                        subtitle: 'A listening experience at your pace',
                        children: _audioSettings(),
                      ),
                      const SizedBox(height: 14),
                      _buildSection(
                        icon: Icons.tune_rounded,
                        title: 'App Settings',
                        subtitle: 'Appearance, reminders, and privacy',
                        children: _appSettings(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _resetSettings,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'Reset to Default',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _secondaryText,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Made for a more mindful reading',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_emerald, _card, _background],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome_rounded, color: _gold, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize your Quran experience',
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 15,
                            color: _gold,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${_settings.pageStyle} · ${_settings.language}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _HeaderArtwork(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _readingSettings() => [
    _valueRow(
      icon: Icons.translate_rounded,
      title: 'Reading language',
      value: _settings.language,
      onTap: () => _selectOption(
        title: 'Reading language',
        options: const ['English', 'Urdu'],
        selected: _settings.language,
        onSelected: (value) => _runSetting(() => _settings.setLanguage(value)),
      ),
    ),
    _valueRow(
      icon: Icons.notes_rounded,
      title: 'Translation',
      value: _settings.translation == 'ur.jalandhry'
          ? 'Fateh Muhammad Jalandhry'
          : 'Sahih International',
      onTap: () => _selectOption(
        title: 'Available translations',
        options: const ['Sahih International', 'Fateh Muhammad Jalandhry'],
        selected: _settings.translation == 'ur.jalandhry'
            ? 'Fateh Muhammad Jalandhry'
            : 'Sahih International',
        onSelected: (value) => _runSetting(
          () => _settings.setTranslation(
            value == 'Fateh Muhammad Jalandhry' ? 'ur.jalandhry' : 'en.sahih',
          ),
        ),
      ),
    ),
    const SizedBox(height: 12),
    _sliderSetting(
      title: 'Arabic font size',
      value: _settings.arabicFontSize,
      min: 18,
      max: 40,
      valueLabel: '${_settings.arabicFontSize.round()} px',
      onChanged: (value) {
        setState(() {});
        _runSetting(() => _settings.setArabicFontSize(value));
      },
    ),
    Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _arabicPreview,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(_settings.textColor),
          fontSize: _settings.arabicFontSize,
          fontFamily: _settings.arabicFont == 'Serif' ? 'serif' : null,
          height: 1.8,
        ),
      ),
    ),
    _valueRow(
      icon: Icons.font_download_outlined,
      title: 'Arabic font style',
      value: _settings.arabicFont,
      onTap: () => _selectOption(
        title: 'Available Arabic fonts',
        options: const ['System default', 'Serif'],
        selected: _settings.arabicFont,
        onSelected: (value) =>
            _runSetting(() => _settings.setArabicFont(value)),
      ),
    ),
    _valueRow(
      icon: Icons.chrome_reader_mode_outlined,
      title: 'Page style',
      value: _settings.pageStyle,
      onTap: () => _selectOption(
        title: 'Reading layout',
        options: const ['Simple', 'Translation view'],
        selected: _settings.pageStyle,
        onSelected: (value) => _runSetting(() => _settings.setPageStyle(value)),
      ),
    ),
  ];

  List<Widget> _audioSettings() => [
    _valueRow(
      icon: Icons.record_voice_over_rounded,
      title: 'Reciter',
      value: 'Mishary Alafasy',
      onTap: () => _selectOption(
        title: 'Available reciter',
        options: const ['Mishary Alafasy'],
        selected: 'Mishary Alafasy',
        onSelected: (_) {},
      ),
    ),
    const Padding(
      padding: EdgeInsets.only(left: 44, right: 12, bottom: 14),
      child: Text(
        'The current Quran audio source provides Alafasy recitation.',
        style: TextStyle(color: _secondaryText, fontSize: 12, height: 1.4),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playback speed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
              return ChoiceChip(
                label: Text('${speed}x'),
                selected: _settings.audioSpeed == speed,
                showCheckmark: false,
                onSelected: (_) =>
                    _runSetting(() => _settings.setAudioSpeed(speed)),
                selectedColor: _emerald,
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                side: BorderSide(
                  color: _settings.audioSpeed == speed
                      ? _accent
                      : Colors.white12,
                ),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
    _switchRow(
      icon: Icons.repeat_rounded,
      title: 'Repeat playback',
      subtitle: 'Replay the current recitation when it ends',
      value: _settings.repeatAyah,
      onChanged: (value) => _runSetting(() => _settings.setRepeatAyah(value)),
    ),
    _switchRow(
      icon: Icons.skip_next_rounded,
      title: 'Play next ayah',
      subtitle: 'Continue automatically after each ayah',
      value: _settings.autoNextAyah,
      onChanged: (value) => _runSetting(() => _settings.setAutoNextAyah(value)),
    ),
  ];

  List<Widget> _appSettings() => [
    _valueRow(
      icon: Icons.palette_outlined,
      title: 'Theme',
      value: switch (_settings.theme) {
        'light' => 'Light',
        'dark' => 'Dark',
        _ => 'System default',
      },
      onTap: () => _selectOption(
        title: 'App theme',
        options: const ['Light', 'Dark', 'System default'],
        selected: switch (_settings.theme) {
          'light' => 'Light',
          'dark' => 'Dark',
          _ => 'System default',
        },
        onSelected: (value) => _runSetting(
          () => _settings.setTheme(switch (value) {
            'Light' => 'light',
            'Dark' => 'dark',
            _ => 'system',
          }),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quran text color',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children:
                const [
                  _TextColorChoice(color: Color(0xFFFFFFFF), label: 'White'),
                  _TextColorChoice(color: Color(0xFFFFF1D4), label: 'Cream'),
                  _TextColorChoice(color: Color(0xFFB7D1CA), label: 'Mint'),
                ].map((choice) {
                  return _TextColorPicker(
                    choice: choice,
                    selectedColor: _settings.textColor,
                    onTap: () => _runSetting(
                      () => _settings.setTextColor(choice.color.toARGB32()),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    ),
    _switchRow(
      icon: Icons.notifications_active_outlined,
      title: 'Daily reading reminder',
      subtitle: _settings.reminderEnabled
          ? 'A daily reminder at ${_reminderTimeLabel()}'
          : 'Get a gentle reminder to read',
      value: _settings.reminderEnabled,
      isLoading: _isUpdatingReminder,
      onChanged: _setReminder,
    ),
    if (_settings.reminderEnabled)
      _valueRow(
        icon: Icons.schedule_rounded,
        title: 'Reminder time',
        value: _reminderTimeLabel(),
        onTap: _chooseReminderTime,
      ),
    _valueRow(
      icon: Icons.shield_outlined,
      title: 'Privacy',
      value: 'Your data and storage',
      onTap: _showPrivacy,
    ),
  ];

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.white.withValues(alpha: 0.04),
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _accent, size: 21),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: _secondaryText, fontSize: 12),
          ),
          iconColor: _secondaryText,
          collapsedIconColor: _secondaryText,
          children: children,
        ),
      ),
    );
  }

  Widget _valueRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, size: 20, color: _gold),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: _secondaryText, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
      onTap: onTap,
    );
  }

  Widget _sliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(valueLabel, style: const TextStyle(color: _accent)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            activeColor: _accent,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLoading = false,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      secondary: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            )
          : Icon(icon, size: 20, color: _gold),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _secondaryText, fontSize: 12),
      ),
      value: value,
      onChanged: isLoading ? null : onChanged,
      activeTrackColor: _accent,
      activeThumbColor: Colors.white,
      inactiveThumbColor: _secondaryText,
      inactiveTrackColor: Colors.white24,
    );
  }
}

class _HeaderArtwork extends StatelessWidget {
  const _HeaderArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 94,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.035),
            ),
          ),
          const Icon(Icons.mosque_rounded, size: 43, color: Color(0xFFD9B76E)),
          const Positioned(
            top: 5,
            right: 9,
            child: Icon(Icons.star_rounded, size: 14, color: Color(0xFF36C9A0)),
          ),
          const Positioned(
            bottom: 6,
            left: 7,
            child: Icon(Icons.circle, size: 5, color: Color(0xFF36C9A0)),
          ),
        ],
      ),
    );
  }
}

class _TextColorChoice {
  const _TextColorChoice({required this.color, required this.label});

  final Color color;
  final String label;
}

class _TextColorPicker extends StatelessWidget {
  const _TextColorPicker({
    required this.choice,
    required this.selectedColor,
    required this.onTap,
  });

  final _TextColorChoice choice;
  final int selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = choice.color.toARGB32() == selectedColor;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _ProfileScreenState._accent : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: choice.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              choice.label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.check,
                color: _ProfileScreenState._accent,
                size: 15,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
