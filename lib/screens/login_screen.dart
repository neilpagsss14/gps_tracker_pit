import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location_tracker/screens/map_screen.dart';
import 'package:location_tracker/screens/signup_screen.dart';
import 'package:location_tracker/widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final box = GetStorage();
  late String username;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title:
            TextRegular(text: 'Log in Page', fontSize: 25, color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/gps.png'),
                      fit: BoxFit.fitHeight,
                    ),
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextFormField(
                onChanged: (String input) {
                  username = input;
                },
                decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextFormField(
                obscureText: _obscureText,
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.password),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.blueAccent.shade100,
              minWidth: 200,
              height: 50,
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: username, password: password);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainMap()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: TextRegular(
                          text: e.toString(),
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  );
                }
              },
              child: TextRegular(
                  text: 'Log in', fontSize: 25, color: Colors.black),
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
                TextRegular(text: 'or', fontSize: 18, color: Colors.white),
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
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SignupScreen()));
              }),
              child:
                  TextBold(text: 'Signup', fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
