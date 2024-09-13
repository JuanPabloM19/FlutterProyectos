import 'package:flutter/material.dart';
import 'package:flutter_practico_1/src/pages/CAMBIARNOMBRE_page.dart';
import 'package:flutter_practico_1/src/pages/home_page.dart';

//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
    'CAMBIARNOMBRE': (BuildContext context) => CAMBIARNOMBRE_page(),
  };
}
