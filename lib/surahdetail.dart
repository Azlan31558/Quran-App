import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SurahDetailScreen extends StatefulWidget {
final int surahId;
final String name;
final String ayah;
final String arabic;

const SurahDetailScreen({
super.key,
required this.surahId,
required this.name,
required this.ayah,
required this.arabic,
});

@override
State<SurahDetailScreen> createState() =>
_SurahDetailScreenState();
}

class _SurahDetailScreenState
extends State<SurahDetailScreen> {
double arabicFontSize = 30;

List<dynamic> ayat = [];
Map<String, dynamic>? surahInfo;

bool isLoading = true;

@override
void initState() {
super.initState();
loadSurahData();
}

Future<void> loadSurahData() async {
try {
final quranString =
await rootBundle.loadString(
'assets/quran.json',
);

  final surahString =
      await rootBundle.loadString(
    'assets/surah_info.json',
  );

  final quranData =
      jsonDecode(quranString);

  final List<dynamic> surahs =
      jsonDecode(surahString);

  final selectedSurah =
      surahs.firstWhere(
    (e) => e['id'] == widget.surahId,
  );

  setState(() {
    ayat = quranData[
            widget.surahId.toString()] ??
        [];

    surahInfo =
        Map<String, dynamic>.from(
      selectedSurah,
    );

    isLoading = false;
  });
} catch (e) {
  debugPrint(e.toString());

  setState(() {
    isLoading = false;
  });
}


}

@override
Widget build(BuildContext context) {
if (isLoading) {
return const Scaffold(
backgroundColor: Color(0xff033B33),
body: Center(
child: CircularProgressIndicator(),
),
);
}

return Scaffold(
  backgroundColor: const Color(0xff033B33),

  appBar: AppBar(
    backgroundColor:
        const Color(0xff033B33),
    elevation: 0,

    title: Text(
      "Surah ${widget.name}",
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  ),

  body: Column(
    children: [

      Container(
        margin:
            const EdgeInsets.all(15),

        padding:
            const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            20,
          ),

          gradient:
              const LinearGradient(
            colors: [
              Color(0xff0A5448),
              Color(0xff0D6B5C),
            ],
          ),
        ),

        child: Column(
          children: [

            Text(
              widget.arabic,                  
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            Text(
              widget.name,
              style:
                  const TextStyle(
                color:
                    Color(0xffF4B400),
              ),
            ),

            const SizedBox(
                height: 5),

            Text(
              "${widget.ayah} Verses",
              style:
                  const TextStyle(
                color:
                    Colors.white70,
              ),
            ),
          ],
        ),
      ),

      Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
        ),

        child: Row(
          children: [

            const Text(
              "Font Size",
              style: TextStyle(
                color: Colors.white,
              ),
            ),

            Expanded(
              child: Slider(
                value:
                    arabicFontSize,

                min: 24,
                max: 40,

                activeColor:
                    const Color(
                  0xffF4B400,
                ),

                onChanged:
                    (value) {
                  setState(() {
                    arabicFontSize =
                        value;
                  });
                },
              ),
            ),
          ],
        ),
      ),

      Expanded(
        child: ListView.builder(
          itemCount:
              ayat.length,

          itemBuilder:
              (context, index) {
            return Container(
              margin:
                  const EdgeInsets
                      .symmetric(
                horizontal: 15,
                vertical: 8,
              ),

              padding:
                  const EdgeInsets
                      .all(18),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xff0A5448,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  18,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  CircleAvatar(
                    radius: 16,

                    backgroundColor:
                        const Color(
                      0xffF4B400,
                    ),

                    child: Text(
                      "${ayat[index]['verse']}",

                      style:
                          const TextStyle(
                        color:
                            Colors
                                .black,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  Text(
                    ayat[index]
                            ['text'] ??
                        '',

                    textAlign:
                        TextAlign
                            .right,

                    textDirection:
                        TextDirection
                            .rtl,

                    style:
                        TextStyle(
                      color:
                          Colors
                              .white,

                      fontSize:
                          arabicFontSize,

                      height: 2,
                    ),
                  ),
                ],
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
