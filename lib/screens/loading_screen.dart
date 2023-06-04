import 'package:flutter/material.dart';

import '../widgets/text_widget.dart';
import 'login_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 250),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Image.asset(
                    'assets/images/gps.png',
                    height: 250,
                    width: 250,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextBold(text: 'GPSpeed', fontSize: 45, color: Colors.amberAccent)
            ],
          ),
        ),
      ),
    );
  }
}
