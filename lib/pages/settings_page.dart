import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserDetails();
  }

  Future<DocumentSnapshot> fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
    } else {
      throw Exception('No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Placeholder image
                    ),
                  ),
                  Text(
                    userData['name'] ?? 'N/A',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData['email'] ?? 'N/A',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Phone Number'),
                    subtitle: Text(userData['phoneNumber'] ?? 'N/A'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Region'),
                    subtitle: Text(userData['region'] ?? 'N/A'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city),
                    title: Text('Town'),
                    subtitle: Text(userData['town'] ?? 'N/A'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Edit Profile'),
                    onTap: () {
                      // Navigate to edit profile page
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
                    onTap: () {
                      // Navigate to change password page
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
