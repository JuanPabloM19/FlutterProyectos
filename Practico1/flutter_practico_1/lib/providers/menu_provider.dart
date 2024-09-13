import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
//Se genera de manera privada la clase
class _MenuProvider {
//Se genera una lista dinámica y se inicializa como una lista vacía
List<dynamic> opciones = [];
//Se define el constructor
_MenuProvider() {
//cargarData();
}
//Convertimos el método cargarData en un Future que permite devolver el
//listado de rutas una vez que se ha leído del archivo JSON
//El Future va a retornar cuando este disponible, la información en una
//lista dinámica
Future<List<dynamic>> cargarData() async {
final resp = await rootBundle.loadString('data/menu_opts.json');
Map dataMap = json.decode(resp);
opciones = dataMap['rutas'];
return opciones;
}
}
//Se crea la instancia del MenuProvider
final menuProvider = new _MenuProvider();