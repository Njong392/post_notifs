import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:post_notifs/components/package_submit_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:post_notifs/components/text_field.dart';
import 'package:post_notifs/pages/home_page.dart';
import 'package:super_bullet_list/bullet_list.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  // text editing controllers
  final namesController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final regionController = TextEditingController();
  final townController = TextEditingController();

  // add new user to users collection
  void addUserDetails() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // reference to users collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // create new document with user's ID as the doc id
      try {
        await users.doc(user.uid).set({
          'email': user.email,
          'name': namesController.text,
          'phoneNumber': phoneNumberController.text,
          'region': regionController.text, // corrected here
          'town': townController.text // corrected here
        });

        Navigator.pop(context);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } catch (e) {
        Navigator.pop(context);

        // show error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.blue[700],
              title: Center(
                child: Text(
                  'Some error occurred',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      }
    } else {
      Navigator.pop(context);

      // show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue[700],
            title: Center(
              child: Text(
                'User is not logged in',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Icon(
                    Icons.note,
                    size: 100,
                    color: Colors.blue[800],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // welcome text
                  Text(
                    'We\'ll need a few details from you',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  const SuperBulletList(
                    isOrdered: true,
                    gap: 4,
                    items: [
                      Text('Input names as they are on legal documents'),
                      Text('Phone Number must be without country code'),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // Name textfield
                  MyTextfield(
                    controller: namesController,
                    hintText: 'Full Names',
                    obscureText: false,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // phone number textfield
                  MyTextfield(
                    controller: phoneNumberController,
                    hintText: 'Phone Number',
                    obscureText: false,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Region textfield
                  MyTextfield(
                    controller: regionController,
                    hintText: 'Region',
                    obscureText: false,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Town textfield
                  MyTextfield(
                    controller: townController,
                    hintText: 'Town',
                    obscureText: false,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // sign in button
                  PackageSubmitButton(
                      text: 'Submit', onTap: () => addUserDetails()),

                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
