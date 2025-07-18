import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tabs/home_tab.dart';
import 'tabs/train_schedule_tab.dart';
import 'tabs/pnr_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/live_running_status_tab.dart';
import 'tabs/more_tab.dart';
import '../user_provider.dart';

class MainNavScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  const MainNavScreen({super.key, required this.userName, required this.userEmail, this.userPhotoUrl});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = userNotifier.value;
    final tabs = [
      HomeTab(userName: user?.displayName ?? widget.userName),
      const LiveRunningStatusTab(),
      const PNRStatusTab(),
      const AboutPage(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: tabs[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_train),
            label: 'Live Running Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'PNR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
} 