import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PackagesPage extends StatefulWidget {
  final Function(String)? onFilteredChanged;
  final String filter;

  const PackagesPage({Key? key, this.onFilteredChanged, required this.filter})
      : super(key: key);

  @override
  _PackagesPageState createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  late Future<List<Map<String, dynamic>>> _packagesFuture;

  @override
  void initState() {
    super.initState();
    _packagesFuture = fetchUserPackages(widget.filter);
  }

  @override
  void didUpdateWidget(PackagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      setState(() {
        _packagesFuture = fetchUserPackages(widget.filter);
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPackages(String filter) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    Query query = FirebaseFirestore.instance
        .collection('packages')
        .where('recipientid', isEqualTo: currentUser.uid);

    // Apply filter to query based on the filter argument
    switch (filter) {
      case 'collected':
        query = query.where('status', isEqualTo: 'collected');
        break;
      case 'NotCollected':
        query = query.where('status', isEqualTo: 'NotCollected');
        break;
      case 'resent':
        query = query.where('status', isEqualTo: 'resent');
        break;
      // No additional filter for 'all'
    }

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> packagesWithPostOfficeInfo = [];

    for (var packageDoc in querySnapshot.docs) {
      var packageData = packageDoc.data() as Map<String, dynamic>;
      var creatorID = packageData['creatorID'];

      var postOfficeDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(creatorID)
          .get();

      if (postOfficeDoc.exists) {
        var postOfficeData = postOfficeDoc.data() as Map<String, dynamic>;

        packageData['town'] = postOfficeData['town'];
        packageData['phoneNumber'] = postOfficeData['phoneNumber'];
      }

      packagesWithPostOfficeInfo.add(packageData);
    }

    packagesWithPostOfficeInfo.sort((a, b) {
      DateTime now = DateTime.now();
      DateTime aDueCollectionDate = a['DueCollectionDate'].toDate();
      DateTime aDueResendDate = a['DueResendDate'].toDate();
      DateTime bDueCollectionDate = b['DueCollectionDate'].toDate();
      DateTime bDueResendDate = b['DueResendDate'].toDate();

      bool aIsOverdue = (a['status'] != 'collected') &&
          (aDueCollectionDate.isBefore(now) || aDueResendDate.isBefore(now));
      bool bIsOverdue = (b['status'] != 'collected') &&
          (bDueCollectionDate.isBefore(now) || bDueResendDate.isBefore(now));

      if (aIsOverdue && !bIsOverdue) return -1;
      if (!aIsOverdue && bIsOverdue) return 1;

      return aDueCollectionDate.compareTo(bDueCollectionDate) +
          aDueResendDate.compareTo(bDueResendDate);
    });

    return packagesWithPostOfficeInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _packagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No packages found.'));
            } else {
              List<Map<String, dynamic>> packages = snapshot.data!;
              return ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  var package = packages[index];
                  DateTime dueCollectionDate =
                      package['DueCollectionDate'].toDate();
                  DateTime dueResendDate = package['DueResendDate'].toDate();
                  return Stack(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${package['countryOfOrigin']}, ${package['senderContact']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Chip(
                                    label: Text(
                                      'Status: ${package['status']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.blue[700],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Post Office: ${package['town']}',
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Phone: ${package['phoneNumber']}',
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                              Text(
                                'Due for collection: ${DateFormat('dd/MM/yy').format(dueCollectionDate)}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Due for resend: ${DateFormat('dd/MM/yy').format(dueResendDate)}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Date collected/resent: ${package['collectedOrResentDate'] == null ? '-' : DateFormat('dd/MM/yy').format(package['collectedOrResentDate'].toDate())}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Category: ${package['category']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if ((dueCollectionDate.isBefore(DateTime.now()) ||
                              dueResendDate.isBefore(DateTime.now())) &&
                          package['collectedOrResentDate'] == null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
