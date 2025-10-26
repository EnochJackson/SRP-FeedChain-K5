import 'package:flutter/material.dart';
import 'donations_tab.dart';
import 'requests_tab.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Tabs for BottomNavigationBar
  final List<Widget> _tabs = const [
    DonationsTab(),
    RequestsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          "FeedChain",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue[700],
        shadowColor: Colors.blueAccent[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: "Profile",
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: "Donations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: "Requests",
          ),
        ],
      ),
    );
  }
}
