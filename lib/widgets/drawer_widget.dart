import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/screens/login_screen.dart';
import 'package:location_tracker/screens/map_screen.dart';
import 'package:location_tracker/widgets/text_widget.dart';

import '../screens/about_gpspeed.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
        stream: userData,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          dynamic data = snapshot.data;
          return SizedBox(
            child: Drawer(
              child: ListView(
                padding: const EdgeInsets.only(top: 0),
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    accountEmail: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.call_end,
                              color: Colors.black,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            TextRegular(
                              text: data['phoneNumber'],
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.mail,
                              color: Colors.black,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            TextRegular(
                              text: data['email'],
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                    accountName: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextBold(
                        text: data['name'],
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/user.png',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: TextRegular(
                      text: 'Home',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MainMap()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                    ),
                    title: TextRegular(
                      text: 'About GPSpeed',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AboutGPSpeed()));
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(
                  //     Icons.password_rounded,
                  //   ),
                  //   title: TextRegular(
                  //     text: 'Change Password',
                  //     fontSize: 12,
                  //     color: Colors.grey,
                  //   ),
                  //   onTap: () {
                  //     Navigator.of(context).pushReplacement(
                  //         MaterialPageRoute(builder: (context) => const MainMap()));
                  //   },
                  // ),
                  // ListTile(
                  //   leading: const Icon(
                  //     Icons.account_box_rounded,
                  //   ),
                  //   title: TextRegular(
                  //     text: "User's Profile",
                  //     fontSize: 12,
                  //     color: Colors.grey,
                  //   ),
                  //   onTap: () {
                  //     Navigator.of(context).pushReplacement(
                  //         MaterialPageRoute(builder: (context) => const MainMap()));
                  //   },
                  // ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: TextRegular(
                      text: 'Exit',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(context).pop(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                  'Logout Confirmation',
                                  style: TextStyle(
                                      fontFamily: 'QBold',
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to Logout?',
                                  style: TextStyle(fontFamily: 'QRegular'),
                                ),
                                actions: <Widget>[
                                  MaterialButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pop(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    },
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontFamily: 'QRegular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
