import 'package:flutter/material.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  static const _background = Color(0xff033B33);
  static const _deepGreen = Color(0xff022C25);
  static const _cardGreen = Color(0xff0A5448);
  static const _gold = Color(0xffF4B400);
  static const _mutedText = Color(0xffB8D0C8);

  static const _monthNames = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha’ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qi’dah',
    'Dhul Hijjah',
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _events = [
    _IslamicEvent(1, 1, 'Islamic New Year', Icons.nights_stay_rounded),
    _IslamicEvent(1, 10, 'Day of Ashura', Icons.water_drop_rounded),
    _IslamicEvent(3, 12, 'Mawlid al-Nabi', Icons.auto_awesome_rounded),
    _IslamicEvent(7, 27, 'Isra and Mi’raj', Icons.star_rounded),
    _IslamicEvent(9, 1, 'First day of Ramadan', Icons.nightlight_round),
    _IslamicEvent(9, 27, 'Laylat al-Qadr', Icons.nightlight_round),
    _IslamicEvent(10, 1, 'Eid al-Fitr', Icons.celebration_rounded),
    _IslamicEvent(12, 9, 'Day of Arafah', Icons.mosque_rounded),
    _IslamicEvent(12, 10, 'Eid al-Adha', Icons.celebration_rounded),
  ];

  late final _HijriDate _today;
  late int _displayYear;
  late int _displayMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = _hijriFromJdn(_gregorianToJdn(now));
    _displayYear = _today.year;
    _displayMonth = _today.month;
    _selectedDay = _today.day;
  }

  int get _daysInDisplayedMonth =>
      _daysInHijriMonth(_displayYear, _displayMonth);

  List<_IslamicEvent> get _displayedEvents => _events
      .where((event) => event.month == _displayMonth)
      .toList(growable: false);

  void _changeMonth(int amount) {
    setState(() {
      _displayMonth += amount;
      if (_displayMonth > 12) {
        _displayMonth = 1;
        _displayYear++;
      } else if (_displayMonth < 1) {
        _displayMonth = 12;
        _displayYear--;
      }
      _selectedDay = 1;
    });
  }

  void _goToCurrentMonth() {
    setState(() {
      _displayYear = _today.year;
      _displayMonth = _today.month;
      _selectedDay = _today.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthStartJdn = _islamicToJdn(_displayYear, _displayMonth, 1);
    final monthStart = _gregorianFromJdn(monthStartJdn);
    final monthEnd = _gregorianFromJdn(
      monthStartJdn + _daysInDisplayedMonth - 1,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Islamic Calendar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _goToCurrentMonth,
            child: const Text(
              'Today',
              style: TextStyle(color: _gold, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthCard(monthStart, monthEnd),
            const SizedBox(height: 18),
            _buildCalendarGrid(monthStartJdn),
            const SizedBox(height: 12),
            _buildDateNote(),
            const SizedBox(height: 28),
            _buildEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(DateTime monthStart, DateTime monthEnd) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff0D6B5C), Color(0xff08483E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _monthArrow(
                icon: Icons.chevron_left_rounded,
                label: 'Previous month',
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_monthNames[_displayMonth - 1]} $_displayYear',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'AH  •  ${_formatGregorianRange(monthStart, monthEnd)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _monthArrow(
                icon: Icons.chevron_right_rounded,
                label: 'Next month',
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: _deepGreen,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedDay ${_monthNames[_displayMonth - 1]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatGregorian(
                          _gregorianFromJdn(
                            _islamicToJdn(
                              _displayYear,
                              _displayMonth,
                              _selectedDay,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: _mutedText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_displayMonth == _today.month &&
                    _displayYear == _today.year &&
                    _selectedDay == _today.day)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthArrow({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon, size: 25),
    );
  }

  Widget _buildCalendarGrid(int monthStartJdn) {
    final gridStartWeekday = monthStartJdn % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: _deepGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (final weekday in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: TextStyle(
                        color: weekday == 'Fri' ? _gold : _mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 3,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final day = index - gridStartWeekday + 1;
              if (day < 1 || day > _daysInDisplayedMonth) {
                return const SizedBox.shrink();
              }

              final isSelected = day == _selectedDay;
              final isToday =
                  _displayMonth == _today.month &&
                  _displayYear == _today.year &&
                  day == _today.day;
              final hasEvent = _events.any(
                (event) => event.month == _displayMonth && event.day == day,
              );

              return Semantics(
                button: true,
                selected: isSelected,
                label:
                    '$day ${_monthNames[_displayMonth - 1]}'
                    '${isToday ? ', today' : ''}'
                    '${hasEvent ? ', Islamic event' : ''}',
                child: InkWell(
                  onTap: () => setState(() => _selectedDay = day),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _gold
                          : isToday
                          ? _cardGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      border: isToday && !isSelected
                          ? Border.all(color: _gold.withValues(alpha: 0.65))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected ? _deepGreen : Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 4,
                          child: hasEvent
                              ? Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected ? _deepGreen : _gold,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendDot(_gold, 'Islamic occasion'),
              const SizedBox(width: 18),
              _legendDot(_cardGreen, 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _mutedText, fontSize: 11)),
      ],
    );
  }

  Widget _buildDateNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, color: _gold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Hijri dates are calculated estimates and may differ by a day '
            'depending on local moon sighting.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Islamic occasions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_displayedEvents.length} this month',
              style: const TextStyle(color: _mutedText, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_displayedEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: _cardGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'No major occasions are listed for this month. '
              'Select a gold-marked day to see an occasion.',
              style: TextStyle(color: _mutedText, height: 1.45),
            ),
          )
        else
          for (final event in _displayedEvents) _buildEventTile(event),
      ],
    );
  }

  Widget _buildEventTile(_IslamicEvent event) {
    final isSelectedDay = event.day == _selectedDay;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _cardGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelectedDay
              ? _gold.withValues(alpha: 0.65)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(event.icon, color: _gold, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.day} ${_monthNames[event.month - 1]}',
                  style: const TextStyle(color: _mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isSelectedDay)
            const Icon(Icons.check_circle_rounded, color: _gold, size: 19),
        ],
      ),
    );
  }
}

class _IslamicEvent {
  const _IslamicEvent(this.month, this.day, this.title, this.icon);

  final int month;
  final int day;
  final String title;
  final IconData icon;
}

class _HijriDate {
  const _HijriDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

int _gregorianToJdn(DateTime date) {
  final a = (14 - date.month) ~/ 12;
  final year = date.year + 4800 - a;
  final month = date.month + (12 * a) - 3;
  return date.day +
      ((153 * month + 2) ~/ 5) +
      (365 * year) +
      (year ~/ 4) -
      (year ~/ 100) +
      (year ~/ 400) -
      32045;
}

int _islamicToJdn(int year, int month, int day) {
  if (month == 13) {
    return _islamicToJdn(year + 1, 1, day);
  }
  final daysBeforeMonth = (59 * (month - 1) + 1) ~/ 2;
  return day +
      daysBeforeMonth +
      (year - 1) * 354 +
      ((3 + 11 * year) ~/ 30) +
      1948440;
}

_HijriDate _hijriFromJdn(int jdn) {
  var year = ((30 * (jdn - 1948440) + 10646) ~/ 10631);
  while (jdn < _islamicToJdn(year, 1, 1)) {
    year--;
  }
  while (jdn >= _islamicToJdn(year + 1, 1, 1)) {
    year++;
  }

  var month = 1;
  while (month < 12 && jdn >= _islamicToJdn(year, month + 1, 1)) {
    month++;
  }
  final day = jdn - _islamicToJdn(year, month, 1) + 1;
  return _HijriDate(year, month, day);
}

int _daysInHijriMonth(int year, int month) {
  final nextMonthYear = month == 12 ? year + 1 : year;
  final nextMonth = month == 12 ? 1 : month + 1;
  return _islamicToJdn(nextMonthYear, nextMonth, 1) -
      _islamicToJdn(year, month, 1);
}

DateTime _gregorianFromJdn(int jdn) {
  final epochJdn = _gregorianToJdn(DateTime(2000, 1, 1));
  return DateTime(2000, 1, 1).add(Duration(days: jdn - epochJdn));
}

String _formatGregorian(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatGregorianRange(DateTime start, DateTime end) {
  if (start.month == end.month && start.year == end.year) {
    return '${start.day}–${end.day} ${_monthAbbreviation(start.month)} '
        '${start.year}';
  }
  return '${_formatGregorian(start)} – ${_formatGregorian(end)}';
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}
