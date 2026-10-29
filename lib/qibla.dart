import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;
  static const double _alignmentTolerance = 6;
  static const double _maximumCompassError = 15;

  Position? _position;
  bool _isLoadingLocation = true;
  bool _permissionPermanentlyDenied = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocation());
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
      _permissionPermanentlyDenied = false;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services to find Qibla.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _permissionPermanentlyDenied = true;
        throw StateError(
          'Allow location access in app settings to find Qibla.',
        );
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw StateError('Location access is required to find Qibla.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) setState(() => _position = position);
    } catch (error) {
      if (mounted) setState(() => _locationError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  double _normalizeDegrees(double degrees) => (degrees % 360 + 360) % 360;

  double _calculateQiblaBearing(double latitude, double longitude) {
    const degreesToRadians = math.pi / 180;
    final latitudeRadians = latitude * degreesToRadians;
    final kaabaLatitudeRadians = _kaabaLatitude * degreesToRadians;
    final longitudeDifference =
        (_kaabaLongitude - longitude) * degreesToRadians;

    final y = math.sin(longitudeDifference) * math.cos(kaabaLatitudeRadians);
    final x =
        math.cos(latitudeRadians) * math.sin(kaabaLatitudeRadians) -
        math.sin(latitudeRadians) *
            math.cos(kaabaLatitudeRadians) *
            math.cos(longitudeDifference);

    return _normalizeDegrees(math.atan2(y, x) / degreesToRadians);
  }

  double _shortestAngleDifference(double target, double heading) {
    return (target - heading + 540) % 360 - 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff033B33),
      appBar: AppBar(
        backgroundColor: const Color(0xff033B33),
        foregroundColor: Colors.white,
        title: const Text('Qibla Direction'),
        actions: [
          IconButton(
            tooltip: 'Refresh location',
            onPressed: _loadLocation,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffF4B400)),
            )
          : _position == null
          ? _buildLocationError()
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;
                if (snapshot.hasError || heading == null) {
                  return _buildCompassUnavailable();
                }

                final bearing = _calculateQiblaBearing(
                  _position!.latitude,
                  _position!.longitude,
                );
                final relativeDirection = _shortestAngleDifference(
                  bearing,
                  heading,
                );
                final accuracy = snapshot.data!.accuracy;
                final compassIsReliable =
                    accuracy != null && accuracy <= _maximumCompassError;
                final isAligned =
                    compassIsReliable &&
                    relativeDirection.abs() <= _alignmentTolerance;
                final statusColor = isAligned
                    ? const Color(0xff58D68D)
                    : const Color(0xffF4B400);
                final instruction = !compassIsReliable
                    ? 'Calibrate compass'
                    : isAligned
                    ? 'Correct direction'
                    : 'Turn ${relativeDirection > 0 ? 'right' : 'left'} '
                          '${relativeDirection.abs().round()}°';

                return _buildCompass(
                  bearing: bearing,
                  heading: _normalizeDegrees(heading),
                  relativeDirection: compassIsReliable ? relativeDirection : 0,
                  isAligned: isAligned,
                  compassIsReliable: compassIsReliable,
                  statusColor: statusColor,
                  instruction: instruction,
                );
              },
            ),
    );
  }

  Widget _buildLocationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Color(0xffF4B400),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _locationError ?? 'Location is needed to calculate Qibla.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _permissionPermanentlyDenied
                  ? Geolocator.openAppSettings
                  : _loadLocation,
              icon: Icon(
                _permissionPermanentlyDenied
                    ? Icons.settings_rounded
                    : Icons.refresh_rounded,
              ),
              label: Text(
                _permissionPermanentlyDenied ? 'Open settings' : 'Try again',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffF4B400),
                foregroundColor: const Color(0xff033B33),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassUnavailable() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded, color: Color(0xffF4B400), size: 48),
            SizedBox(height: 16),
            Text(
              'Compass sensor is unavailable on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass({
    required double bearing,
    required double heading,
    required double relativeDirection,
    required bool isAligned,
    required bool compassIsReliable,
    required Color statusColor,
    required String instruction,
  }) {
    final compassSize = math.min(MediaQuery.sizeOf(context).width - 48, 300.0);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mosque_rounded,
              size: 54,
              color: Color(0xffF4B400),
            ),
            const SizedBox(height: 12),
            const Text(
              'Qibla Direction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bearing ${bearing.round()}° from north',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: compassSize,
                  height: compassSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff0A5448),
                    border: Border.all(color: statusColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.16),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  child: Text(
                    'N',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: relativeDirection * math.pi / 180,
                  child: Icon(
                    Icons.navigation_rounded,
                    size: compassSize * 0.55,
                    color: statusColor,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAligned
                        ? Icons.check_circle_rounded
                        : compassIsReliable
                        ? Icons.screen_rotation_alt_rounded
                        : Icons.explore_off_rounded,
                    color: statusColor,
                    size: 21,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    instruction,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!compassIsReliable) ...[
              const SizedBox(height: 9),
              const Text(
                'Move your phone in a figure-eight to calibrate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Compass heading ${heading.round()}°',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
