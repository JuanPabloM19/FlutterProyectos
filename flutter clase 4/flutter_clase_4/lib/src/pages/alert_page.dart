import 'package:flutter/material.dart';

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Mostrar Alerta'),
          onPressed: () => _mostrarAlerta(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_circle_left_outlined),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  } //Caja de contenido de la alerta

  void _mostrarAlerta(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text('Título'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Contenido de la tarjeta de alerta'),
                FlutterLogo(
                  size: 100,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
