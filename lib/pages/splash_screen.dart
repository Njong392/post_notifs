import 'dart:async';
import 'package:flutter/material.dart';
import 'package:post_notifs/pages/auth_page.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToNextPage(context);
  }

  void _navigateToNextPage(BuildContext context) {
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            //logo
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Image.asset(
                'lib/assets/logo.png',
                height: 200,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
