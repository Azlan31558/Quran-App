import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  // =========================================================
  // COLORS
  // =========================================================

  final Color background = const Color(0xff033B33);
  final Color darkGreen = const Color(0xff022C25);
  final Color cardColor = const Color(0xff0A5448);
  final Color gold = const Color(0xffF4B400);
  final Color lightGold = const Color(0xffFFD86A);

  // =========================================================
  // LOCATION (Default: Sahiwal, Overwritten by GPS if allowed)
  // =========================================================

  double latitude = 30.6682;
  double longitude = 73.1114;
  String locationName = "Sahiwal";

  // =========================================================
  // VARIABLES
  // =========================================================

  bool isLoading = true;
  String errorMessage = "";

  Timer? countdownTimer;

  List<Map<String, dynamic>> prayers = [];

  String nextPrayerName = "--";
  String nextPrayerTime = "--";

  Duration remainingTime = Duration.zero;

  String hijriDate = "--";
  String gregorianDate = "--";

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetch();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  // =========================================================
  // DETERMINE LOCATION & FETCH
  // =========================================================

  Future<void> _initializeLocationAndFetch() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          latitude = position.latitude;
          longitude = position.longitude;
          locationName = "Current Location";
        }
      }
    } catch (e) {
      // Fallback to default Sahiwal coordinates on error
    }

    await fetchPrayerTimes();
  }

  // =========================================================
  // FETCH API
  // =========================================================

  Future<void> fetchPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final today = DateTime.now();

      final url = Uri.parse(
        "https://api.aladhan.com/v1/timings/"
        "${today.day.toString().padLeft(2, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.year}"
        "?latitude=$latitude"
        "&longitude=$longitude"
        "&method=2",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final timings = data["data"]["timings"];
        final dateData = data["data"]["date"];
        final hijri = dateData["hijri"];
        final gregorian = dateData["gregorian"];

        final newPrayers = [
          {
            "name": "Fajr",
            "time": timings["Fajr"],
            "endTime": timings["Sunrise"],
            "endLabel": "Sunrise",
          },
          {
            "name": "Dhuhr",
            "time": timings["Dhuhr"],
            "endTime": timings["Asr"],
          },
          {
            "name": "Asr",
            "time": timings["Asr"],
            "endTime": timings["Maghrib"],
          },
          {
            "name": "Maghrib",
            "time": timings["Maghrib"],
            "endTime": timings["Isha"],
          },
          {
            "name": "Isha",
            "time": timings["Isha"],
            "endTime": timings["Midnight"],
            "endLabel": "Islamic midnight",
          },
        ];

        if (!mounted) return;

        setState(() {
          prayers = newPrayers;

          hijriDate =
              "${hijri["day"]} ${hijri["month"]["en"]} ${hijri["year"]}";
          gregorianDate =
              "${gregorian["day"]} ${gregorian["month"]["en"]} ${gregorian["year"]}";

          isLoading = false;
        });

        calculateNextPrayer();
        startCountdown();
      } else {
        throw Exception("Failed to load prayer times");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Unable to load prayer times. Check your connection.";
      });
    }
  }

  // =========================================================
  // CONVERT API TIME TO DATETIME
  // =========================================================

  DateTime? getPrayerDateTime(String time, DateTime date) {
    final cleanTime = time.split(" ").first;
    final parts = cleanTime.split(":");
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // =========================================================
  // FIND NEXT PRAYER
  // =========================================================

  void calculateNextPrayer() {
    if (prayers.isEmpty) return;

    final now = DateTime.now();

    for (final prayer in prayers) {
      final prayerTime = getPrayerDateTime(
        prayer["time"]?.toString() ?? "",
        now,
      );

      if (prayerTime != null && prayerTime.isAfter(now)) {
        setState(() {
          nextPrayerName = prayer["name"].toString();
          nextPrayerTime = formatPrayerTime(prayerTime);
          remainingTime = prayerTime.difference(now);
        });
        return;
      }
    }

    // =======================================================
    // IF ALL PRAYERS FINISHED -> TOMORROW FAJR
    // =======================================================

    final tomorrow = now.add(const Duration(days: 1));
    final fajr = prayers.first;
    final fajrTime = getPrayerDateTime(
      fajr["time"]?.toString() ?? "",
      tomorrow,
    );
    if (fajrTime == null) return;

    setState(() {
      nextPrayerName = "Fajr";
      nextPrayerTime = formatPrayerTime(fajrTime);
      remainingTime = fajrTime.difference(now);
    });
  }

  // =========================================================
  // START COUNTDOWN
  // =========================================================

  void startCountdown() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now();
      DateTime? nextTime;

      for (final prayer in prayers) {
        final prayerTime = getPrayerDateTime(
          prayer["time"]?.toString() ?? "",
          now,
        );

        if (prayerTime != null && prayerTime.isAfter(now)) {
          nextTime = prayerTime;
          break;
        }
      }

      if (nextTime == null && prayers.isNotEmpty) {
        final tomorrow = now.add(const Duration(days: 1));
        nextTime = getPrayerDateTime(
          prayers.first["time"]?.toString() ?? "",
          tomorrow,
        );
      }

      if (nextTime == null) return;

      final difference = nextTime.difference(now);

      if (difference.inSeconds <= 0) {
        calculateNextPrayer();
      } else {
        setState(() {
          remainingTime = difference;
        });
      }
    });
  }

  // =========================================================
  // FORMAT COUNTDOWN
  // =========================================================

  String formatRemainingTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, "0");
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");

    return "$hours:$minutes:$seconds";
  }

  // =========================================================
  // FORMAT PRAYER TIME
  // =========================================================

  String formatPrayerTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, "0");
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return "$displayHour:$minute $period";
  }

  // =========================================================
  // CHECK NEXT PRAYER
  // =========================================================

  bool isNextPrayer(String name) {
    return name == nextPrayerName;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prayer Times",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              locationName,
              style: TextStyle(
                color: lightGold,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _initializeLocationAndFetch,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: gold))
          : errorMessage.isNotEmpty
          ? _buildError()
          : _buildBody(),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: lightGold, size: 55),
            const SizedBox(height: 15),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeLocationAndFetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MAIN BODY
  // =========================================================

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // =================================================
          // NEXT PRAYER CARD
          // =================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff0A5448), Color(0xff0D6B5C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_rounded, color: lightGold, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      "NEXT PRAYER",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  nextPrayerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nextPrayerTime,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: gold.withOpacity(.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: lightGold, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        "${formatRemainingTime(remainingTime)} Remaining",
                        style: TextStyle(
                          color: lightGold,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // DATE CARD
          // =================================================
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateColumn("Hijri", hijriDate),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(.10),
                ),
                _buildDateColumn("Gregorian", gregorianDate),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // PRAYER LIST
          // =================================================
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: prayers.length,
              itemBuilder: (context, index) {
                final prayer = prayers[index];
                final bool active = isNextPrayer(prayer["name"].toString());

                return _buildPrayerCard(prayer, active);
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DATE COLUMN
  // =========================================================

  Widget _buildDateColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(.50),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRAYER CARD
  // =========================================================

  Widget _buildPrayerCard(Map<String, dynamic> prayer, bool active) {
    final String name = prayer["name"].toString();
    final String time = prayer["time"].toString();
    final String? endTime = prayer["endTime"]?.toString();
    final String? endLabel = prayer["endLabel"]?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: active ? gold : cardColor,
        borderRadius: BorderRadius.circular(18),
        border: active
            ? null
            : Border.all(color: Colors.white.withOpacity(.05)),
        boxShadow: active
            ? [
                BoxShadow(
                  color: gold.withOpacity(.18),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active
                ? Colors.black.withOpacity(.10)
                : gold.withOpacity(.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            active
                ? Icons.notifications_active_rounded
                : Icons.access_time_rounded,
            color: active ? Colors.black : lightGold,
            size: 21,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          active ? "Next Prayer" : "Prayer Window",
          style: TextStyle(
            color: active
                ? Colors.black.withOpacity(.60)
                : Colors.white.withOpacity(.45),
            fontSize: 10,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatApiTime(time),
              style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (endTime != null && endTime.isNotEmpty)
              Text(
                "to ${_formatApiTime(endTime)}",
                style: TextStyle(
                  color: active
                      ? Colors.black.withOpacity(.70)
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (endLabel != null)
              Text(
                endLabel,
                style: TextStyle(
                  color: active
                      ? Colors.black.withOpacity(.55)
                      : Colors.white54,
                  fontSize: 9,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FORMAT API TIME
  // =========================================================

  String _formatApiTime(String time) {
    final clean = time.split(" ").first;
    final parts = clean.split(":");
    if (parts.length < 2) return "--";

    final parsedHour = int.tryParse(parts[0]);
    final parsedMinute = int.tryParse(parts[1]);
    if (parsedHour == null ||
        parsedMinute == null ||
        parsedHour > 23 ||
        parsedMinute > 59) {
      return "--";
    }

    int hour = parsedHour;
    final minute = parsedMinute.toString().padLeft(2, "0");
    final period = hour >= 12 ? "PM" : "AM";

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return "$hour:$minute $period";
  }
}
