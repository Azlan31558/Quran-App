import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  final Color background = const Color(0xff033B33);
  final Color darkGreen = const Color(0xff022C25);
  final Color cardColor = const Color(0xff0A5448);
  final Color gold = const Color(0xffF4B400);
  final Color lightGold = const Color(0xffFFD86A);

  static const List<Map<String, dynamic>> features = [
    {
      "title": "Quran",
      "subtitle": "Read Quran",
      "icon": Icons.menu_book_rounded,
      "route": "/quran",
    },
    {
      "title": "Prayer",
      "subtitle": "Prayer Times",
      "icon": Icons.access_time_rounded,
      "route": "/prayer",
    },
    {
      "title": "Qibla",
      "subtitle": "Find Qibla",
      "icon": Icons.explore_rounded,
      "route": "/qibla",
    },
    {
      "title": "Tasbeeh",
      "subtitle": "Dhikr Counter",
      "icon": Icons.fingerprint_rounded,
      "route": "/tasbeeh",
    },
    {
      "title": "Dua",
      "subtitle": "Daily Duas",
      "icon": Icons.favorite_rounded,
      "route": "/dua",
    },
    {
      "title": "Hadith",
      "subtitle": "Daily Hadith",
      "icon": Icons.auto_stories_rounded,
      "route": "/hadith",
    },
     
    {
      "title": "Calendar",
      "subtitle": "Islamic Calendar",
      "icon": Icons.calendar_month_rounded,
      "route": "/calendar",
    },
     {
      "title": "Allah Names",
      "subtitle": "99 Name of Allah",
      "icon": Icons.home,
      "route": "/allahNames",
    },
    {
      "title": "Zakat",
      "subtitle": "Zakat Calculate",
      "icon": Icons.calculate,
      "route": "/zakat",
    },
      {
      "title": "mosques",
      "subtitle": "Mosque Find",
      "icon": Icons.calculate,
      "route": "/mosques",
    },
      {
      "title": "audioPlayer",
      "subtitle": "Quran Audio",
      "icon": Icons.audiotrack_outlined,
      "route": "/audioPlayer",
    },
  ];

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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),

        title: const Text(
          "Explore",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // HEADER
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor,
                      darkGreen,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: gold.withOpacity(.18),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,

                      decoration: BoxDecoration(
                        color: gold.withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: gold.withOpacity(.20),
                        ),
                      ),

                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: lightGold,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Islamic Essentials",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Explore all your spiritual tools",
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(.55),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // =========================
              // SECTION TITLE
              // =========================

              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,

                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Text(
                    "All Features",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "Choose what you want to explore",
                style: TextStyle(
                  color: Colors.white.withOpacity(.45),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // FEATURE GRID
              // =========================

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: features.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                ),

                itemBuilder: (context, index) {
                  final feature = features[index];

                  return _buildFeatureCard(
                    context,
                    feature,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FEATURE CARD
  // =========================================================

  Widget _buildFeatureCard(
    BuildContext context,
    Map<String, dynamic> feature,
  ) {
    final String title =
        feature["title"] as String;

    final String subtitle =
        feature["subtitle"] as String;

    final IconData icon =
        feature["icon"] as IconData;

    final String route =
        feature["route"] as String;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(23),

        onTap: () {
          Navigator.pushNamed(
            context,
            route,
          );
        },

        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(23),

            border: Border.all(
              color: Colors.white.withOpacity(.07),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),

            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -25,
                  top: -25,

                  child: Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gold.withOpacity(.055),
                    ),
                  ),
                ),

                // Small decorative dot
                Positioned(
                  right: 20,
                  top: 20,

                  child: Container(
                    width: 6,
                    height: 6,

                    decoration: BoxDecoration(
                      color: gold.withOpacity(.45),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Card content
                Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // Icon
                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: gold.withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(16),

                          border: Border.all(
                            color:
                                gold.withOpacity(.18),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  gold.withOpacity(.05),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),

                        child: Icon(
                          icon,
                          color: lightGold,
                          size: 25,
                        ),
                      ),

                      const Spacer(),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(.48),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // Arrow
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,

                        children: [
                          Container(
                            width: 28,
                            height: 28,

                            decoration: BoxDecoration(
                              color:
                                  gold.withOpacity(.10),
                              shape: BoxShape.circle,

                              border: Border.all(
                                color:
                                    gold.withOpacity(.15),
                              ),
                            ),

                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: lightGold,
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
}