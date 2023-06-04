import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location_tracker/screens/login_screen.dart';

import '../widgets/text_widget.dart';

class SignupScreen extends StatelessWidget {
  late String username;
  late String password;

  final box = GetStorage();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: TextRegular(text: 'Sign up', fontSize: 25, color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/gps.png',
                height: 250,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 10, bottom: 10),
                child: TextFormField(
                    onChanged: ((value) {
                      username = value;
                    }),
                    decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 10, bottom: 10),
                child: TextFormField(
                    obscureText: true,
                    onChanged: ((value) {
                      password = value;
                    }),
                    decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.password),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.blue,
                minWidth: 340,
                height: 45,
                onPressed: () {
                  box.write('username', username);
                  box.write('password', password);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: TextRegular(
                    text: 'Register', fontSize: 20, color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                    child: Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextRegular(
                      text: 'Already have an account',
                      fontSize: 18,
                      color: Colors.white),
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    width: 50,
                    child: Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: (() {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                }),
                child:
                    TextBold(text: 'Log in', fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
