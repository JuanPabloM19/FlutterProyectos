import 'package:flutter/material.dart';
import 'package:flutter_app_final/pages/home_page.dart';
import 'package:flutter_app_final/pages/listAdmin_page.dart';
import 'package:flutter_app_final/pages/login_page.dart';
import 'package:flutter_app_final/pages/settings_page.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/pages/wheater_page.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/utils/navigation_bar.dart';
import 'package:provider/provider.dart';

//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => const HomePage(),
    'login': (BuildContext context) => const LoginPage(),
    'settings': (BuildContext context) => SettingsPage(),
    'today': (BuildContext context) => const TodayPage(),
    'wheater': (BuildContext context) => WeatherPage(),
    'main': (BuildContext context) {
      return Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final isAdmin = userProvider.isAdmin;
          print('Redirigiendo a MainPage con isAdmin: $isAdmin');
          return MainPage(isAdmin: isAdmin);
        },
      );
    },
    'calendar': (BuildContext context) => const CalendarPage(),
    'rentalList': (BuildContext context) => RentalListPage(),
  };
}
