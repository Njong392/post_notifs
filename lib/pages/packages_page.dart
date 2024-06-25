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
  late Future<List<DocumentSnapshot>> _packagesFuture;

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

  Future<List<DocumentSnapshot>> fetchUserPackages(String filter) async {
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

    List<DocumentSnapshot> sortedPackages = querySnapshot.docs;
    sortedPackages.sort((a, b) {
      DateTime aDueCollectionDate = a['DueCollectionDate'].toDate();
      DateTime aDueResendDate = a['DueResendDate'].toDate();
      DateTime bDueCollectionDate = b['DueCollectionDate'].toDate();
      DateTime bDueResendDate = b['DueResendDate'].toDate();
      bool aIsOverdue = aDueCollectionDate.isBefore(DateTime.now()) ||
          aDueResendDate.isBefore(DateTime.now());
      bool bIsOverdue = bDueCollectionDate.isBefore(DateTime.now()) ||
          bDueResendDate.isBefore(DateTime.now());

      if (aIsOverdue && !bIsOverdue) {
        return -1; // a comes before b because it is overdue and b is not
      } else if (!aIsOverdue && bIsOverdue) {
        return 1; // b comes before a because it is overdue and a is not
      } else {
        // If both are overdue or neither, sort by the earliest DueCollectionDate
        int dueDateComparison =
            aDueCollectionDate.compareTo(bDueCollectionDate);
        if (dueDateComparison != 0) {
          return dueDateComparison;
        } else {
          // If DueCollectionDate is the same, sort by DueResendDate
          return aDueResendDate.compareTo(bDueResendDate);
        }
      }
    });

    return sortedPackages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _packagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot package = snapshot.data![index];
                  DateTime dueCollectionDate =
                      package['DueCollectionDate'].toDate();
                  DateTime dueResendDate = package['DueResendDate'].toDate();

                  return Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
                          leading: Icon(
                            Icons.card_giftcard,
                            color: Colors.blue[700],
                          ),
                          title: Text(
                            '${package['countryOfOrigin']}, ${package['senderContact']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due to be collected: ${DateFormat('dd/MM/yy').format(package['DueCollectionDate'].toDate())}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Due to be resent: ${DateFormat('dd/MM/yy').format(package['DueResendDate'].toDate())}',
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
                                SizedBox(height: 5),
                                Chip(
                                  label: Text(
                                    'Status: ${package['status']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue[700],
                                ),
                              ],
                            ),
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
