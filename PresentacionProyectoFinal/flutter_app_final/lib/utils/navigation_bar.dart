import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/listAdmin_page.dart';
import 'package:flutter_app_final/pages/settings_page.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final bool isAdmin;
  const MainPage({Key? key, required this.isAdmin})
      : super(key: key); // Se recibe isAdmin

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = widget.isAdmin
        ? [RentalListPage(), WeatherPage(), SettingsPage()]
        : [CalendarPage(), WeatherPage(), SettingsPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF21283F),
        currentIndex: _currentPageIndex,
        selectedItemColor: Color(0xFF80B3FF),
        unselectedItemColor: Color(0xFFEBEBF5).withOpacity(0.6),
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
  