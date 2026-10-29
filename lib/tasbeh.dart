import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int count = 0;
  int goal = 99;

  void incrementCounter() async {
    setState(() {
      count++;
    });

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void resetCounter() {
    setState(() {
      count = 0;
    });
  }

  double get progress {
    if (goal == 0) return 0;

    double value = count / goal;

    return value > 1 ? 1 : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),

      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),

        title: const Text(
          "Digital Tasbeeh",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // Daily Goal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff0A5448),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    const Text(
                      "Daily Goal",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<int>(
                      dropdownColor: const Color.fromARGB(255, 243, 219, 1),
                      value: goal,
                      underline: const SizedBox(),

                      items: const [
                        DropdownMenuItem(
                          value: 33,
                          child: Text(
                            "33",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),

                        DropdownMenuItem(
                          value: 99,
                          child: Text(
                            "99",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),

                        DropdownMenuItem(
                          value: 1000,
                          child: Text(
                            "1000",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          goal = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Progress Circle
              Stack(
                alignment: Alignment.center,

                children: [
                  SizedBox(
                    height: 260,
                    width: 260,

                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,

                      backgroundColor: Colors.white12,

                      valueColor:
                          const AlwaysStoppedAnimation(
                        Color(0xffF4B400),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      const Text(
                        "Count",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Main Counter Button
              GestureDetector(
                onTap: incrementCounter,

                child: Container(
                  height: 140,
                  width: 140,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: const Color(0xffF4B400),

                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 15,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.black,
                    size: 55,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Count / Goal
              Text(
                "$count / $goal",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: resetCounter,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Reset Counter",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
  
