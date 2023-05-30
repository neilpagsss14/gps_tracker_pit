import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../widgets/drawer_widget.dart';
import 'package:latlong2/latlong.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const Drawer(
          child: DrawerWidget(),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Sample Google Map',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(8.477217, 124.645920),
            zoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ));
  }
}
