import 'package:flutter/material.dart';

class ContadorPage extends StatefulWidget {
  const ContadorPage({super.key});

  @override
  _ContadorPageState createState() => _ContadorPageState();
}

class _ContadorPageState extends State<ContadorPage> {
  final _estiloTexto = const TextStyle(fontSize: 25);
  int _conteo = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador con AppBar'),
        backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Número de clicks:', style: _estiloTexto),
            Text('$_conteo', style: _estiloTexto),
            ElevatedButton(
              onPressed: _multiplicar, 
              child: const Text('Multiplicar X 2'),
            ),
          ],
        ),
      ),
      floatingActionButton: _crearBotones(context),
    );
  }

  Widget _crearBotones(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: _cerar,
          child: const Icon(Icons.exposure_zero),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _restar,
          child: const Icon(Icons.remove),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _sumar,
          child: const Icon(Icons.add),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_circle_left_outlined),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
      ],
    );
  }

  void _cerar() {
    setState(() {
      _conteo = 0;
    });
  }

  void _restar() {
    setState(() {
      if (_conteo > 0) {
        _conteo--;
      }
    });
  }

  void _sumar() {
    setState(() {
      _conteo++;
    });
  }

  void _multiplicar() {
    setState(() {
      _conteo *= 2;
    });
  }
}
