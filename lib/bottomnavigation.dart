import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/activityscreen.dart';
import 'package:trainez_miniproject/Screens/profilescreen.dart';
import 'package:trainez_miniproject/Screens/welcomescreen.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class AllScreen extends StatefulWidget {
  final String? userId;
  const AllScreen({required this.userId,super.key});

  @override
  State<AllScreen> createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  int _currentSelectedIndex = 0;

  late List<Widget> _pages;

   @override
  void initState() {
    super.initState();
    _pages = [
      WelcomeScreen(userId: widget.userId),
      ActivityScreen(),
      ProfileScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_pages[_currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentSelectedIndex,
        onTap: (newIndex){
          setState(() {
            _currentSelectedIndex = newIndex;
          });
        },
        fixedColor: MyColor.orange,
        items: [ const
        BottomNavigationBarItem(icon: Icon(Icons.home_filled,),label: 'Home', ),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center),label: 'Activities'),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile')
      ])
    );
  }
}