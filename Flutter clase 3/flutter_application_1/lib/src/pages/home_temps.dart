import 'package:flutter/material.dart';

class HomePageTemp extends StatelessWidget {
  // Se genera una lista con opciones para un ListTile
  final List<String> opciones = ['Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        // Utiliza el método _crearItemsMap para generar la lista de widgets
        children: _crearItemsMap(),
      ),
    );
  }

  List<Widget> _crearItemsMap() {
    // El método map regresa una nueva lista de iterables con elementos creados en la función anónima
    // Se genera una variable de tipo iterable
    var widgets = opciones.map((item) {
      // Se genera un widget de tipo Column para generar el item ListTile y el Divider
      return Column(
        children: [
          ListTile(
            // Propiedad título
            title: Text('Map ' + item),
            // Propiedad subtítulo
            subtitle: Text('Subtítulo del ListTile'),
            // Widget que se coloca al inicio. Se agrega un icono como hijo
            leading: Icon(Icons.computer),
            // Widget que se coloca al final. Se agrega un icono como hijo
            trailing: Icon(Icons.arrow_forward_ios_sharp),
            // onTap es un método al cual se le pueden asignar funcionalidades
            onTap: () {},
          ),
          Divider(),
        ],
      );
    }).toList(); // Convierte el iterable en una lista

    return widgets;
  }
}
