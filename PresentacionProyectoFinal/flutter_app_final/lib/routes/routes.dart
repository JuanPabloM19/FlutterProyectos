import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/home_page.dart';
import 'package:flutter_app_final/pages/login_page.dart';
import 'package:flutter_app_final/pages/new_assigment_page.dart';
import 'package:flutter_app_final/pages/settings_page.dart';
import 'package:flutter_app_final/pages/shedule_page.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';

//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => const HomePage(),
    'login': (BuildContext context) => const LoginPage(),
    'newAssigment': (BuildContext context) => const NewAssigmentPage(),
    'settings': (BuildContext context) => const SettingsPage(),
    'shedule': (BuildContext context) => const ShedulePage(),
    'today': (BuildContext context) => const TodayPage(),
    'wheater': (BuildContext context) => WeatherPage(),
    'main': (BuildContext context) => MainPage(), // Agrega esta línea
  };
}