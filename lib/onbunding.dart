import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/quran.png",
      "title": "Read Holy Quran",
      "subtitle":
          "Read, Listen and Learn Quran with translations and tafsir."
    },
    {
      "image": "assets/images/mosque.png",
      "title": "Prayer Time & Qibla",
      "subtitle":
          "Get accurate prayer times and Qibla direction anywhere."
    },
    {
      "image": "assets/images/dua.png",
      "title": "Islamic Companion",
      "subtitle":
          "Tasbeeh, Duas, Hadith and everything in one place."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      body: SafeArea(
        child: Column(
          children: [

            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    "/location",
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.menu_book_rounded
                                : index == 1
                                    ? Icons.mosque
                                    : Icons.favorite,
                            size: 100,
                            color: const Color(0xffF4B400),
                          ),
                        ),

                        const SizedBox(height: 50),

                        Text(
                          pages[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          pages[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: currentIndex == index ? 28 : 10,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xffF4B400)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF4B400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (currentIndex == pages.length - 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        "/location",
                      );
                    } else {
                      _controller.nextPage(
                        duration:
                            const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentIndex == pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}