import 'package:cloud_firestore/cloud_firestore.dart';

Future addData(data, latitude, longitude, speedWithUnit, googleMapsLink) async {
  final docUser = FirebaseFirestore.instance.collection('Data').doc();

  final json = {
    'timestamp': data,
    'latitude': latitude,
    'longitude': longitude,
    'speed': speedWithUnit,
    'googleMapsLink': googleMapsLink,
  };

  await docUser.set(json);
}
