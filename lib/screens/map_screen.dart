import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/services/add_data.dart';
import 'package:location_tracker/widgets/text_widget.dart';
import '../widgets/drawer_widget.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  Timer? timer;

  late String report = '';
  late DatabaseReference dbRef;

  Map<String, dynamic> trackerData = {
    'latitude': 0.0,
    'longitude': 0.0,
    'speed': 0.0,
  };

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    determinePosition();
    getLocation();
    dbRef = FirebaseDatabase.instance.ref().child("Tracker");
    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      uploadDataToDatabase();
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  double speed = 0.0;
  double newSpeed = 0.0;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final timestamp = DateTime.now(); // Get the current timestamp
  late double lat = 0;
  late double long = 0;
  bool hasLoaded = false;
  bool isStoringData = true;
  Position? previousPosition;

  getLocation() async {
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

      // // Update the trackerData with the new location and speed
      // trackerData['latitude'] = position.latitude;
      // trackerData['longitude'] = position.longitude;
      // trackerData['speed'] = newSpeed;
      // dbRef.push().set({
      //   'latitude': position.latitude,
      //   'longitude': position.longitude,
      //   'speed': newSpeed,
      // });
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

  void uploadDataToDatabase() {
    if (isStoringData && previousPosition != null) {
      final latitude = previousPosition!.latitude;
      final longitude = previousPosition!.longitude;

      // Format the speed with 2 decimal places
      final formattedSpeed = newSpeed.toStringAsFixed(2);

      // Add "km/h" text to the formatted speed
      final speedWithUnit = '$formattedSpeed km/h';

      // Create a Google Maps link using the latitude and longitude
      final googleMapsLink =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      Map<String, dynamic> trackerData = {
        'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
        'latitude': latitude,
        'longitude': longitude,
        'speed': speedWithUnit,
        'googleMapsLink': googleMapsLink,
      };
      addData(DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp), latitude,
          longitude, speedWithUnit, googleMapsLink);
      dbRef.push().set(trackerData);
    }
  }

  void eraseDataInDatabase() {
    // Implement the logic to erase the data in the database using the appropriate database operations

    // For example, if you're using Firebase Realtime Database, you can use the `remove()` method to remove all data under the "Tracker" node:
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("Tracker");
    dbRef.remove().then((_) {
      Fluttertoast.showToast(
        msg: "Data erased successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Failed to erase data: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14.4746,
    );
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 337),
            child: RawMaterialButton(
              onPressed: () {
                setState(() {
                  isStoringData = !isStoringData;
                });
                Fluttertoast.showToast(
                  msg: isStoringData
                      ? 'Data storing enabled'
                      : 'Data storing disabled',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
              },
              elevation: 2.0,
              fillColor:
                  isStoringData ? Colors.deepPurpleAccent : Colors.transparent,
              padding: const EdgeInsets.all(15),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.cloud_done_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: () {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: TextRegular(
                          text: "Are you sure you want to erase all the data",
                          fontSize: 22,
                          color: Colors.black),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              eraseDataInDatabase();
                            },
                            child: const Text('Yes')),
                      ],
                    );
                  });
            },
            child: const SizedBox(
              child: Icon(Icons.auto_delete_rounded),
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
