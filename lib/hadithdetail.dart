import 'package:flutter/material.dart';

class HadithDetailScreen extends StatelessWidget {
  const HadithDetailScreen({super.key});

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
          "Sahih Bukhari",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {

          return Container(
            margin:
                const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff0A5448),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Hadith #${index + 1}",
                  style: const TextStyle(
                    color: Color(0xffF4B400),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "The Messenger of Allah ﷺ said: Actions are judged by intentions.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}