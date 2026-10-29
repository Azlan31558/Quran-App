import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
 
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends State<LocationPermissionScreen> {
  bool isLoading = false;

  Future<void> requestLocation() async {
    setState(() {
      isLoading = true;
    });

    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position =
          await Geolocator.getCurrentPosition();

      debugPrint(
          "Lat: ${position.latitude}  Long: ${position.longitude}");

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/notification",
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 90,
                  color: Color(0xffF4B400),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Enable Location",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "We need your location to calculate accurate Prayer Times and Qibla Direction.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : requestLocation,
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
                          "Allow Location",
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
                    "/notification",
                  );
                },
                child: const Text(
                  "Skip For Now",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}