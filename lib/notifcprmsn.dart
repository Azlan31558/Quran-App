import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool isLoading = false;

  Future<void> requestNotification() async {
    setState(() {
      isLoading = true;
    });

    PermissionStatus status =
        await Permission.notification.request();

    if (status.isGranted) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/home",
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/home",
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
        
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.08),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 90,
                    color: Color(0xffF4B400),
                  ),
                ),
        
                const SizedBox(height: 40),
        
                const Text(
                  "Enable Notifications",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        
                const SizedBox(height: 15),
        
                Text(
                  "Receive Prayer Time Alerts, Azan Reminders and Daily Islamic Updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontSize: 16,
                  ),
                ),
        
                const SizedBox(height: 50),
        
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Color(0xffF4B400)),
                          SizedBox(width: 10),
                          Text(
                            "Prayer Time Alerts",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 12),
        
                      Row(
                        children: [
                          Icon(Icons.mosque,
                              color: Color(0xffF4B400)),
                          SizedBox(width: 10),
                          Text(
                            "Azan Notifications",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 12),
        
                      Row(
                        children: [
                          Icon(Icons.menu_book,
                              color: Color(0xffF4B400)),
                          SizedBox(width: 10),
                          Text(
                            "Daily Hadith & Ayah",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        
                const SizedBox(height: 40),
        
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : requestNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xffF4B400),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            "Allow Notifications",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
        
                const SizedBox(height: 15),
        
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      "/home",
                    );
                  },
                  child: const Text(
                    "Maybe Later",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
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