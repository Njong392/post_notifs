import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:post_notifs/pages/details_page.dart';
import 'package:post_notifs/pages/home_page.dart';
import 'package:post_notifs/pages/login_or_register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<DocumentSnapshot>? userDetails;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        userDetails =
            FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      } else {
        userDetails = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // user is logged in
              if (snapshot.hasData) {
                Future<DocumentSnapshot> userDetails = FirebaseFirestore
                    .instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get();

                return FutureBuilder<DocumentSnapshot>(
                    future: userDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                                {};

                        if (data.containsKey('name') &&
                            data['name'].trim().isNotEmpty) {
                          return HomePage();
                        } else {
                          return DetailsPage();
                        }
                      }
                    });
              }

              //user is not logged in
              else {
                return LoginOrRegister();
              }
            }));
  }
}
