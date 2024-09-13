import 'package:flutter/material.dart';
//Se genera una variable privada, ya que solo se utilizara en este entorno
//Esta variable será un mapa (Map) que tendrá dos valores.
//Por un lado un string como llave, y un IconData como valor de esa llave
final _icons = <String, IconData>{
'warning_amber': Icons.warning_amber,
};
//Se genera un método que devuelve un icono, recibiendo como parámetro un string con el nombre del mismo
Icon getIcon(String nombreIcono) {
//Se retorna un widget de tipo Icon con el parámetro de tipo string
//que recibe como parametro getIcon
//Tambien se agrega la propiedad de color del mismo
return Icon(
_icons[nombreIcono],
color: Colors.blue,
);
}
