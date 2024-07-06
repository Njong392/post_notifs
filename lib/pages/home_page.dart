import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_notifs/pages/login_page.dart';
import 'package:post_notifs/pages/packages_page.dart';
import 'package:post_notifs/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _currentFilter = 'all';
  late final List<Widget> _pages;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateFilter(String newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      PackagesPage(onFilteredChanged: _updateFilter, filter: _currentFilter),
      SettingsPage()
    ];
  }

  final List<String> _titles = ['Packages', 'Settings'];

  //final user = FirebaseAuth.instance.currentUser;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: _selectedIndex == 0
            ? [
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor:
                        Colors.blue.shade800, // Dropdown background color
                  ),
                  child: DropdownButton<String>(
                    value: _currentFilter,
                    icon: const Icon(Icons.arrow_downward), // Dropdown icon
                    iconEnabledColor: Colors.white, // Icon color
                    iconSize: 24, // Icon size
                    elevation: 16, // Shadow elevation
                    style: const TextStyle(color: Colors.white), // Text style
                    underline: Container(
                      height: 2,
                      color: Colors.blue.shade100, // Underline color
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _updateFilter(value);
                        // Assuming PackagesPage can react to changes in its constructor parameter.
                        (_pages[0] as PackagesPage)
                            .onFilteredChanged
                            ?.call(value);
                      }
                    },
                    items: ['all', 'collected', 'Notcollected', 'resent']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: signUserOut,
                  tooltip: 'Log out',
                  color: Colors.white,
                ),
              ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        selectedItemColor: Colors.blue[700],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}
