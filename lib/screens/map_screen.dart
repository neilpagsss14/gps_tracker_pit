import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/widgets/text_widget.dart';
import '../widgets/drawer_widget.dart';
import 'dart:math' as math;

import '../widgets/toast_widget.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  final locationController = TextEditingController();
  final speedController = TextEditingController();

  late String report = '';
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();
    dbRef = FirebaseDatabase.instance.ref().child("Tracker");
  }

  double speed = 0.0;
  double newSpeed = 0.0;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late double lat = 0;
  late double long = 0;
  bool hasLoaded = false;
  Position? previousPosition;

  getLocation() async {
    controller:
    locationController;
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (previousPosition != null) {
      setState(() {
        speed = calculateSpeed(previousPosition!, currentPosition);
      });
    }

    Geolocator.getPositionStream().listen((position) {
      setState(() {
        newSpeed = position.speed * 4;
      });
    });

    // if (previousPosition != null) {
    //   // Calculate speed based on previous and current positions
    //   double speed = calculateSpeed(previousPosition!, currentPosition);

    //   // Use the speed as needed (e.g., update UI)
    //   // print('Speed: $speed meters per second');
    //   // Text('Speed: ${speed.toStringAsFixed(2)} meters per seconds');
    // }
    setState(() {
      lat = currentPosition.latitude;
      long = currentPosition.longitude;
      hasLoaded = true;
      previousPosition = currentPosition;
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

    // Calculate time difference in hours
    final double timeDifference =
        (currentPosition.timestamp!.millisecondsSinceEpoch -
                previousPosition.timestamp!.millisecondsSinceEpoch) /
            1000 /
            3600;

    // Calculate speed in kilometers per hour
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: () async {
              showToast('Data has been stored to the Database');
              Map<String, String> tracker = {
                'location': locationController.text,
                'speed': speedController.text,
              };
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => const MainMap()),
              // );
              dbRef.push().set(tracker);
            },
            child: const SizedBox(
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              child: Icon(Icons.cloud_done_rounded),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          FloatingActionButton(
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainMap()),
              );
            },
            child: const SizedBox(
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),

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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.send),
        //     onPressed: () {
        //       // Perform search action
        //     },
        //   ),
        // ],
      ),
      body: hasLoaded
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        buildingsEnabled: true,
                        myLocationEnabled: true,
                        compassEnabled: true,
                        zoomControlsEnabled: false,
                        indoorViewEnabled: true,
                        mapToolbarEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: kGooglePlex,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 65.0,
                                height: 65.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white54,
                                ),
                              ),
                              Text(
                                newSpeed.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 35),
                                child: TextBold(
                                    text: 'km/h',
                                    fontSize: 15,
                                    color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

  // _sendSMS() {
  //   String sms1 = 'sms:096694201160';
  //   launchUrl(sms1 as Uri);
  // }
}
