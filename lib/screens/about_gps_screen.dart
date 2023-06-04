import 'package:flutter/material.dart';

class AboutGPSpeed extends StatefulWidget {
  const AboutGPSpeed({super.key});

  @override
  State<AboutGPSpeed> createState() => _AboutGPSpeedState();
}

class _AboutGPSpeedState extends State<AboutGPSpeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'About GPSpeed',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.PNG',
                ),
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/images/title.PNG',
                ),
                const SizedBox(
                  height: 15,
                ),
                Image.asset(
                  'assets/images/members.PNG',
                ),
              ],
            ),
          ),
        ));
  }
}
