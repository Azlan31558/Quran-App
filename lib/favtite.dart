import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {

  final List<Map<String, dynamic>> favorites = [
    {
      "type": "Quran",
      "title": "Surah Al-Fatihah",
      "subtitle": "Verse 1",
      "icon": Icons.menu_book,
    },
    {
      "type": "Dua",
      "title": "Morning Dua",
      "subtitle": "Daily Azkar",
      "icon": Icons.favorite,
    },
    {
      "type": "Hadith",
      "title": "Actions are judged by intentions",
      "subtitle": "Sahih Bukhari",
      "icon": Icons.book,
    },
    {
      "type": "Allah Name",
      "title": "Ar-Rahman",
      "subtitle": "The Most Merciful",
      "icon": Icons.star,
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff033B33),

      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Search Favorites",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                filled: true,
                fillColor:
                    const Color(0xff0A5448),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {

                final item =
                    favorites[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xff0A5448),
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(
                              0xffF4B400),
                      child: Icon(
                        item["icon"],
                        color: Colors.black,
                      ),
                    ),

                    title: Text(
                      item["title"],
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      item["subtitle"],
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),

                    trailing: PopupMenuButton(
                      color:
                          const Color(
                              0xff0A5448),
                      icon: const Icon(
                        Icons.more_vert,
                        color:
                            Colors.white,
                      ),
                      itemBuilder: (context) {
                        return [

                          const PopupMenuItem(
                            value: "share",
                            child: Text(
                              "Share",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white,
                              ),
                            ),
                          ),

                          const PopupMenuItem(
                            value: "delete",
                            child: Text(
                              "Delete",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white,
                              ),
                            ),
                          ),
                        ];
                      },
                      onSelected: (value) {

                        if (value ==
                            "delete") {

                          setState(() {
                            favorites.removeAt(
                                index);
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}