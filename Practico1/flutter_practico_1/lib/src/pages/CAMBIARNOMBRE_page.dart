import 'package:flutter/material.dart';

class CAMBIARNOMBRE_page extends StatelessWidget {
  const CAMBIARNOMBRE_page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAMBIAR NOMBRE'),
      ),
//Se crea el botón para regresar a la pantalla inicial
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_circle_left_outlined),
        onPressed: () {
//Con el método Navigator se genera la ruta para volver a la pantalla
//principal a partir del context
          Navigator.pop(context);
        },
      ),
    );
  }
}