import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/animated_container.dart';
import 'package:flutter_application_1/src/pages/card_page.dart';
//Se importa los archivos de cada una de las ruta
import 'package:flutter_application_1/src/pages/home_page.dart';
import 'package:flutter_application_1/src/pages/alert_page.dart';
import 'package:flutter_application_1/src/pages/avatar_page.dart';
import 'package:flutter_application_1/src/pages/contador_page.dart';
import 'package:flutter_application_1/src/pages/input_page.dart';
import 'package:flutter_application_1/src/pages/listview_page.dart';
import 'package:flutter_application_1/src/pages/practica2.dart';
import 'package:flutter_application_1/src/pages/practica3_page.dart';
import 'package:flutter_application_1/src/pages/slider_page.dart';

//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
    'alert': (BuildContext context) => AlertPage(),
    'avatar': (BuildContext context) => AvatarPage(),
    'card': (BuildContext context) => CardPage(),
    'contador': (BuildContext context) => ContadorPage(),
    'animated': (BuildContext context) => AnimatedContainerPage(),
    'inputs_txt': (BuildContext context) => InputPage(),
    'practica2': (BuildContext context) => Practica2Page(),
    'slider': (BuildContext context) => SliderPage(),
    'list': (BuildContext context) => ListaPage(),
    'practica3': (BuildContext context) => Practica3Page(),
  };
}
