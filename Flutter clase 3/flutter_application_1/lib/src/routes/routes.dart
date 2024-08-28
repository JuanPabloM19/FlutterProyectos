import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/card_page.dart';
//Se importa los archivos de cada una de las ruta
import 'package:flutter_application_1/src/pages/home_page.dart';
import 'package:flutter_application_1/src/pages/alert_page.dart';
import 'package:flutter_application_1/src/pages/avatar_page.dart';
import 'package:flutter_application_1/src/pages/contador_page.dart';

//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
    'alert': (BuildContext context) => AlertPage(),
    'avatar': (BuildContext context) => AvatarPage(),
    'card':(BuildContext context) => CardPage(),
    'contador':(BuildContext context) => ContadorPage(),
  };
}
