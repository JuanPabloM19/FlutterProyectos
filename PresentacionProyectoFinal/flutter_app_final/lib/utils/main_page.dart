import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/settings_page.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    TodayPage(),
    WeatherPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Clima',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
