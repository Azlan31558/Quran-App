import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holyquran/explore_home.dart';
import 'package:http/http.dart' as http;
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // =========================================================
  // COLORS
  // =========================================================

  final Color background = const Color(0xff033B33);
  final Color darkGreen = const Color(0xff022C25);
  final Color cardColor = const Color(0xff0A5448);
  final Color gold = const Color(0xffF4B400);
  final Color lightGold = const Color(0xffFFD86A);

  // =========================================================
  // QURAN IMAGE
  // =========================================================

  final String quranImage =
      "https://images.unsplash.com/photo-1609599006353-e629aaabfeae?auto=format&fit=crop&w=1200&q=85";

  // =========================================================
  // SAHIWAL LOCATION
  // =========================================================

  final double latitude = 30.6682;
  final double longitude = 73.1114;

  // =========================================================
  // PRAYER DATA
  // =========================================================

  List<Map<String, String>> prayers = [];

  String nextPrayerName = "Loading...";
  String nextPrayerTime = "--:--";

  Duration remainingTime = Duration.zero;

  bool isPrayerLoading = true;

  String prayerError = "";

  Timer? countdownTimer;

  // =========================================================
  // FEATURE CARDS
  // =========================================================

  final List<Map<String, dynamic>> features = [
    {
      "title": "Quran",
      "subtitle": "Read Quran",
      "icon": Icons.menu_book_rounded,
    },
    {
      "title": "Prayer",
      "subtitle": "Prayer Times",
      "icon": Icons.access_time_rounded,
    },
    {
      "title": "Qibla",
      "subtitle": "Find Qibla",
      "icon": Icons.explore_rounded,
    },
    {
      "title": "Tasbeeh",
      "subtitle": "Dhikr Counter",
      "icon": Icons.fingerprint_rounded,
    },
  ];

  // =========================================================
  // INIT STATE
  // =========================================================

  @override
  void initState() {
    super.initState();

    fetchPrayerTimes();
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
  // FETCH PRAYER TIMES FROM API
  // =========================================================

  Future<void> fetchPrayerTimes() async {
    if (mounted) {
      setState(() {
        isPrayerLoading = true;
        prayerError = "";
      });
    }

    try {
      final now = DateTime.now();

      final day =
          now.day.toString().padLeft(2, "0");

      final month =
          now.month.toString().padLeft(2, "0");

      final year = now.year.toString();

      final url = Uri.parse(
        "https://api.aladhan.com/v1/timings/"
        "$day-$month-$year"
        "?latitude=$latitude"
        "&longitude=$longitude"
        "&method=2",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          "Prayer API Error: ${response.statusCode}",
        );
      }

      final data = jsonDecode(response.body);

      final timings =
          data["data"]["timings"];

      final List<Map<String, String>> loadedPrayers = [
        {
          "name": "Fajr",
          "time": timings["Fajr"].toString(),
        },
        {
          "name": "Dhuhr",
          "time": timings["Dhuhr"].toString(),
        },
        {
          "name": "Asr",
          "time": timings["Asr"].toString(),
        },
        {
          "name": "Maghrib",
          "time": timings["Maghrib"].toString(),
        },
        {
          "name": "Isha",
          "time": timings["Isha"].toString(),
        },
      ];

      if (!mounted) return;

      setState(() {
        prayers = loadedPrayers;
        isPrayerLoading = false;
      });

      // Calculate first next prayer
      updateNextPrayer();

      // Start live countdown
      startCountdown();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPrayerLoading = false;
        prayerError = "Unable to load prayer times";
      });
    }
  }

  // =========================================================
  // GET PRAYER DATETIME
  // =========================================================

  DateTime prayerDateTime(
    String prayerTime,
    DateTime date,
  ) {
    // API normally returns:
    // 04:52
    // 12:30
    // 18:58

    final cleanTime =
        prayerTime.split(" ").first;

    final parts =
        cleanTime.split(":");

    final hour =
        int.parse(parts[0]);

    final minute =
        int.parse(parts[1]);

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  // =========================================================
  // UPDATE NEXT PRAYER
  // =========================================================

  void updateNextPrayer() {
    if (prayers.isEmpty) return;

    final now = DateTime.now();

    // Check today's prayers
    for (final prayer in prayers) {
      final time = prayerDateTime(
        prayer["time"]!,
        now,
      );

      if (time.isAfter(now)) {
        if (!mounted) return;

        setState(() {
          nextPrayerName =
              prayer["name"]!;

          nextPrayerTime =
              formatTime(time);

          remainingTime =
              time.difference(now);
        });

        return;
      }
    }

    // =======================================================
    // ALL PRAYERS ARE FINISHED
    // NEXT = TOMORROW FAJR
    // =======================================================

    final tomorrow =
        now.add(const Duration(days: 1));

    final fajr =
        prayers.first;

    final fajrTime =
        prayerDateTime(
      fajr["time"]!,
      tomorrow,
    );

    if (!mounted) return;

    setState(() {
      nextPrayerName = "Fajr";

      nextPrayerTime =
          formatTime(fajrTime);

      remainingTime =
          fajrTime.difference(now);
    });
  }

  // =========================================================
  // START LIVE COUNTDOWN
  // =========================================================

  void startCountdown() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || prayers.isEmpty) {
          return;
        }

        final now = DateTime.now();

        DateTime? nextTime;

        String? nextName;

        // Find next prayer
        for (final prayer in prayers) {
          final time = prayerDateTime(
            prayer["time"]!,
            now,
          );

          if (time.isAfter(now)) {
            nextTime = time;
            nextName = prayer["name"];
            break;
          }
        }

        // ===================================================
        // TOMORROW FAJR
        // ===================================================

        if (nextTime == null) {
          final tomorrow =
              now.add(const Duration(days: 1));

          final fajr = prayers.first;

          nextTime = prayerDateTime(
            fajr["time"]!,
            tomorrow,
          );

          nextName = "Fajr";
        }

        final difference =
            nextTime.difference(now);

        // ===================================================
        // UPDATE UI
        // ===================================================

        setState(() {
          nextPrayerName = nextName!;

          nextPrayerTime =
              formatTime(nextTime!);

          remainingTime = difference;
        });
      },
    );
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

  String formatTime(DateTime time) {
    int hour = time.hour;

    final minute =
        time.minute.toString().padLeft(2, "0");

    final period =
        hour >= 12 ? "PM" : "AM";

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return "$hour:$minute $period";
  }

  // =========================================================
  // FORMAT REMAINING
  // =========================================================

  String formatRemaining(Duration duration) {
    if (duration.isNegative) {
      return "00:00:00";
    }

    final hours =
        duration.inHours
            .toString()
            .padLeft(2, "0");

    final minutes =
        (duration.inMinutes % 60)
            .toString()
            .padLeft(2, "0");

    final seconds =
        (duration.inSeconds % 60)
            .toString()
            .padLeft(2, "0");

    return "$hours:$minutes:$seconds";
  }

  // =========================================================
  // NAVIGATION
  // =========================================================

  void openFeature(String title) {
    switch (title) {
      case "Quran":
        Navigator.pushNamed(context, "/quran");
        break;

      case "Prayer":
        Navigator.pushNamed(context, "/prayer");
        break;

      case "Qibla":
        Navigator.pushNamed(context, "/qibla");
        break;

      case "Tasbeeh":
        Navigator.pushNamed(context, "/tasbeeh");
        break;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Assalamu Alaikum",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: lightGold,
                  size: 13,
                ),

                const SizedBox(width: 4),

                Text(
                  "Sahiwal, Pakistan",
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(.60),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          // Notification
          Container(
            margin:
                const EdgeInsets.only(right: 8),

            child: Material(
              color:
                  Colors.white.withOpacity(.07),
              shape: const CircleBorder(),

              child: InkWell(
                customBorder:
                    const CircleBorder(),

                onTap: () {},

                child: Padding(
                  padding:
                      const EdgeInsets.all(11),

                  child: Stack(
                    children: [
                      const Icon(
                        Icons
                            .notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),

                      Positioned(
                        right: 0,
                        top: 0,

                        child: Container(
                          width: 7,
                          height: 7,

                          decoration:
                              BoxDecoration(
                            color: gold,
                            shape:
                                BoxShape.circle,
                            border:
                                Border.all(
                              color:
                                  background,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile
          Container(
            margin:
                const EdgeInsets.only(right: 16),

            child: Material(
              color:
                  gold.withOpacity(.14),
              shape: const CircleBorder(),

              child: InkWell(
                customBorder:
                    const CircleBorder(),

                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/profile",
                  );
                },

                child: Padding(
                  padding:
                      const EdgeInsets.all(10),

                  child: Icon(
                    Icons.person_rounded,
                    color: lightGold,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // HERO
              _buildHeroCard(),

              const SizedBox(height: 28),

              // EXPLORE TITLE
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Explore",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Everything you need in one place",
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(.48),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  Material(
                    color:
                        Colors.transparent,

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(20),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ExploreScreen(),
                          ),
                        );
                      },

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(
                          color: gold
                              .withOpacity(.09),
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                          border:
                              Border.all(
                            color: gold
                                .withOpacity(.22),
                          ),
                        ),

                        child: Row(
                          children: [
                            Text(
                              "View All",
                              style:
                                  TextStyle(
                                color:
                                    lightGold,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                                width: 5),

                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color:
                                  lightGold,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FOUR CARDS
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount:
                    features.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.17,
                ),

                itemBuilder:
                    (context, index) {
                  final feature =
                      features[index];

                  return _buildFeatureCard(
                    feature,
                  );
                },
              ),

              const SizedBox(height: 24),

              // DAILY REMINDER
              _buildDailyReminder(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // =====================================================
      // BOTTOM NAVIGATION
      // =====================================================

      bottomNavigationBar:
          _buildBottomNavigationBar(),
    );
  }

  // =========================================================
  // HERO CARD
  // =========================================================

  Widget _buildHeroCard() {
    return Container(
      height: 245,

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.25),
            blurRadius: 25,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(28),

        child: Stack(
          children: [
            // =================================================
            // IMAGE
            // =================================================

            Positioned.fill(
              child: Image.network(
                quranImage,
                fit: BoxFit.cover,

                loadingBuilder:
                    (context, child,
                        loadingProgress) {
                  if (loadingProgress ==
                      null) {
                    return child;
                  }

                  return Container(
                    color: darkGreen,
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color: gold,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },

                errorBuilder:
                    (context, error,
                        stackTrace) {
                  return Container(
                    color: darkGreen,
                    child: Center(
                      child: Icon(
                        Icons
                            .menu_book_rounded,
                        color: gold,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),

            // =================================================
            // DARK OVERLAY
            // =================================================

            Positioned.fill(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.centerLeft,
                    end:
                        Alignment.centerRight,

                    colors: [
                      Colors.black
                          .withOpacity(.88),
                      Colors.black
                          .withOpacity(.58),
                      Colors.black
                          .withOpacity(.20),
                    ],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,
                      Colors.black
                          .withOpacity(.65),
                    ],
                  ),
                ),
              ),
            ),

            // =================================================
            // DECORATIVE CIRCLE
            // =================================================

            Positioned(
              right: -45,
              top: -45,

              child: Container(
                width: 145,
                height: 145,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  border: Border.all(
                    color: gold
                        .withOpacity(.16),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            Positioned(
              right: -15,
              top: -15,

              child: Container(
                width: 80,
                height: 80,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color: gold
                      .withOpacity(.07),
                ),
              ),
            ),

            // =================================================
            // QURAN BUTTON
            // =================================================

            Positioned(
              right: 16,
              top: 16,

              child: Material(
                color:
                    Colors.transparent,

                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(22),

                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/quran",
                    );
                  },

                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.black
                          .withOpacity(.30),

                      borderRadius:
                          BorderRadius.circular(
                              22),

                      border:
                          Border.all(
                        color: gold
                            .withOpacity(.35),
                      ),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Icon(
                          Icons
                              .menu_book_rounded,
                          color:
                              lightGold,
                          size: 16,
                        ),

                        const SizedBox(
                            width: 6),

                        const Text(
                          "Quran",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        const SizedBox(
                            width: 5),

                        const Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          color:
                              Colors.white54,
                          size: 9,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =================================================
            // PRAYER INFORMATION
            // =================================================

            Positioned(
              left: 0,
              right: 0,
              top: 65,
              bottom: 0,

              child: Material(
                color:
                    Colors.transparent,

                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/prayer",
                    );
                  },

                  child: Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      20,
                      15,
                      20,
                      18,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      mainAxisAlignment:
                          MainAxisAlignment
                              .end,

                      children: [
                        // =================================================
                        // NEXT PRAYER LABEL
                        // =================================================

                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,

                              decoration:
                                  BoxDecoration(
                                color: gold,
                                shape:
                                    BoxShape
                                        .circle,
                              ),
                            ),

                            const SizedBox(
                                width: 7),

                            const Text(
                              "NEXT PRAYER",
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                letterSpacing:
                                    1.4,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 7),

                        // =================================================
                        // DYNAMIC PRAYER NAME
                        // =================================================

                        Row(
                          children: [
                            Text(
                              isPrayerLoading
                                  ? "Loading..."
                                  : nextPrayerName,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 27,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                                width: 9),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(5),

                              decoration:
                                  BoxDecoration(
                                color: gold
                                    .withOpacity(
                                        .16),
                                shape:
                                    BoxShape
                                        .circle,
                              ),

                              child: Icon(
                                Icons
                                    .arrow_forward_rounded,
                                color:
                                    lightGold,
                                size: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 6),

                        // =================================================
                        // LIVE REMAINING
                        // =================================================

                        Row(
                          children: [
                            Icon(
                              Icons
                                  .timer_outlined,
                              color:
                                  lightGold,
                              size: 15,
                            ),

                            const SizedBox(
                                width: 6),

                            Text(
                              isPrayerLoading
                                  ? "Calculating..."
                                  : "${formatRemaining(remainingTime)} Remaining",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        .72),
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 12),

                        // =================================================
                        // ACTUAL PRAYER TIME
                        // =================================================

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .black
                                .withOpacity(
                                    .24),

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),

                            border:
                                Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      .10),
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [
                              Icon(
                                Icons
                                    .access_time_rounded,
                                color:
                                    lightGold,
                                size: 16,
                              ),

                              const SizedBox(
                                  width: 7),

                              Text(
                                isPrayerLoading
                                    ? "--:--"
                                    : nextPrayerTime,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                  width: 8),

                              Text(
                                "Tap for prayer times",
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          .48),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FEATURE CARD
  // =========================================================

  Widget _buildFeatureCard(
    Map<String, dynamic> feature,
  ) {
    final String title =
        feature["title"] as String;

    final String subtitle =
        feature["subtitle"] as String;

    final IconData icon =
        feature["icon"] as IconData;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(23),

        onTap: () {
          openFeature(title);
        },

        child: Ink(
          decoration:
              BoxDecoration(
            color: cardColor,

            borderRadius:
                BorderRadius.circular(23),

            border: Border.all(
              color:
                  Colors.white.withOpacity(.07),
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.14),
                blurRadius: 12,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(23),

            child: Stack(
              children: [
                Positioned(
                  right: -22,
                  top: -22,

                  child: Container(
                    width: 82,
                    height: 82,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          gold.withOpacity(.06),
                    ),
                  ),
                ),

                Positioned(
                  right: 20,
                  top: 18,

                  child: Container(
                    width: 6,
                    height: 6,

                    decoration:
                        BoxDecoration(
                      color:
                          gold.withOpacity(.40),
                      shape:
                          BoxShape.circle,
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Container(
                        width: 52,
                        height: 42,

                        decoration:
                            BoxDecoration(
                          color:
                              gold.withOpacity(.12),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      16),

                          border:
                              Border.all(
                            color: gold
                                .withOpacity(
                                    .18),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: gold
                                  .withOpacity(
                                      .06),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),

                        child: Icon(
                          icon,
                          color:
                              lightGold,
                          size: 25,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        title,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 15,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                          height: 3),

                      Text(
                        subtitle,
                        style:
                            TextStyle(
                          color: Colors
                              .white
                              .withOpacity(
                                  .48),
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),

                      const SizedBox(
                          height: 3),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .end,

                        children: [
                          Container(
                            width: 27,
                            height: 27,

                            decoration:
                                BoxDecoration(
                              color: gold
                                  .withOpacity(
                                      .10),
                              shape:
                                  BoxShape
                                      .circle,

                              border:
                                  Border.all(
                                color: gold
                                    .withOpacity(
                                        .16),
                              ),
                            ),

                            child: Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color:
                                  lightGold,
                              size: 14,
                            ),
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
      ),
    );
  }

  // =========================================================
  // DAILY REMINDER
  // =========================================================

  Widget _buildDailyReminder() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,

          colors: [
            cardColor,
            darkGreen,
          ],
        ),

        borderRadius:
            BorderRadius.circular(22),

        border:
            Border.all(
          color:
              gold.withOpacity(.22),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.12),
            blurRadius: 15,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration:
                BoxDecoration(
              color:
                  gold.withOpacity(.12),

              borderRadius:
                  BorderRadius.circular(15),

              border:
                  Border.all(
                color:
                    gold.withOpacity(.18),
              ),
            ),

            child: Icon(
              Icons.auto_awesome_rounded,
              color:
                  lightGold,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Daily Reminder",
                  style:
                      TextStyle(
                    color:
                        lightGold,
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  "Take a moment to remember Allah.",
                  style:
                      TextStyle(
                    color: Colors
                        .white
                        .withOpacity(
                            .65),
                    fontSize: 11,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 31,
            height: 31,

            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(.06),
              shape:
                  BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .arrow_forward_rounded,
              color:
                  Colors.white70,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration:
          BoxDecoration(
        color: darkGreen,

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.25),
            blurRadius: 20,
            offset:
                const Offset(0, -5),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child:
            BottomNavigationBar(
          backgroundColor:
              Colors.transparent,

          elevation: 0,

          type:
              BottomNavigationBarType
                  .fixed,

          currentIndex: 0,

          selectedItemColor:
              lightGold,

          unselectedItemColor:
              Colors.white
                  .withOpacity(.38),

          selectedFontSize: 10,

          unselectedFontSize: 9,

          showUnselectedLabels:
              true,

          onTap: (index) {
            switch (index) {
              case 0:
                break;

              case 1:
                Navigator.pushNamed(
                  context,
                  "/quran",
                );
                break;

              case 2:
                Navigator.pushNamed(
                  context,
                  "/tasbeeh",
                );
                break;

              case 3:
                Navigator.pushNamed(
                  context,
                  "/qibla",
                );
                break;

              case 4:
                Navigator.pushNamed(
                  context,
                  "/profile",
                );
                break;
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              activeIcon: Icon(
                Icons.home_rounded,
              ),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.menu_book_outlined,
              ),
              activeIcon: Icon(
                Icons.menu_book_rounded,
              ),
              label: "Quran",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons
                    .fingerprint_outlined,
              ),
              activeIcon: Icon(
                Icons
                    .fingerprint_rounded,
              ),
              label: "Tasbeeh",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons
                    .compass_calibration_outlined,
              ),
              activeIcon: Icon(
                Icons.compass_calibration_rounded,
              ),
              label: "Qibla",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons
                    .person_outline_rounded,
              ),
              activeIcon: Icon(
                Icons.person_rounded,
              ),
              label: "Audio",
            ),
          ],
        ),
      ),
    );
  }
}