import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/drawer_widget.dart';
import 'dart:math' as math;

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();
  }

  double speed = 0.0;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late double lat = 0;
  late double long = 0;
  bool hasLoaded = false;
  Position? previousPosition;

  getLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    if (previousPosition != null) {
      // Calculate speed based on previous and current positions
      double speed = calculateSpeed(previousPosition!, currentPosition);

      // Use the speed as needed (e.g., update UI)
      print('Speed: $speed meters per second');
    }
    setState(() {
      lat = currentPosition.latitude;
      long = currentPosition.longitude;
      hasLoaded = true;
      previousPosition = currentPosition;
      speed = calculateSpeed(previousPosition!, currentPosition);
    });
  }

  double calculateSpeed(Position previousPosition, Position currentPosition) {
    const int earthRadius = 6371000; // in meters

    final double lat1 = previousPosition.latitude;
    final double lon1 = previousPosition.longitude;
    final double lat2 = currentPosition.latitude;
    final double lon2 = currentPosition.longitude;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c; // in meters

    // Calculate time difference in seconds
    final double timeDifference =
        (currentPosition.timestamp!.millisecondsSinceEpoch -
                previousPosition.timestamp!.millisecondsSinceEpoch) /
            1000;

    // Calculate speed in meters per second
    final double speed = distance / timeDifference;

    return speed;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14.4746,
    );
    return Scaffold(
      drawer: const Drawer(
        child: DrawerWidget(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Home Screen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: hasLoaded
          ? Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    buildingsEnabled: true,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    initialCameraPosition: kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                Text('Speed: ${speed.toStringAsFixed(2)} meters per second'),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
