import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueFinderScreen extends StatelessWidget {
  const MosqueFinderScreen({super.key});

  Future<void> openMap() async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=mosque",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosques = [
      {
        "name": "Jamia Masjid",
        "distance": "1.2 km",
      },
      {
        "name": "Masjid Al Noor",
        "distance": "2.8 km",
      },
      {
        "name": "Masjid Al Rahman",
        "distance": "4.1 km",
      },
      {
        "name": "Masjid Bilal",
        "distance": "5.5 km",
      },
    ];

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
          "Nearby Mosques",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Search Mosque...",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: const Color(0xff0A5448),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: mosques.length,
                itemBuilder: (context, index) {

                  final mosque = mosques[index];

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff0A5448),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: ListTile(

                      leading: const CircleAvatar(
                        backgroundColor:
                            Color(0xffF4B400),
                        child: Icon(
                          Icons.mosque,
                          color: Colors.black,
                        ),
                      ),

                      title: Text(
                        mosque["name"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        mosque["distance"]!,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      trailing: IconButton(
                        onPressed: openMap,
                        icon: const Icon(
                          Icons.directions,
                          color: Color(0xffF4B400),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xffF4B400),
        onPressed: openMap,
        icon: const Icon(
          Icons.map,
          color: Colors.black,
        ),
        label: const Text(
          "Open Maps",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}