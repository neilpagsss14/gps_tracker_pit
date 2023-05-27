import 'package:flutter/material.dart';
import 'package:location_tracker/widgets/text_widget.dart';

import '../widgets/drawer_widget.dart';

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
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextRegular(
                text: '\n\n\n\n\n\n\n\n\n\nDisplay Map',
                fontSize: 25,
                color: Colors.black),
          ],
        ),
      ),
    );
  }
}
