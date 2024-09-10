import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

void main() => runApp(const Practica3Page());

class Practica3Page extends StatefulWidget {
  const Practica3Page({super.key});

  @override
  State<Practica3Page> createState() => _Practica3PageState();
}

class _Practica3PageState extends State<Practica3Page> {
  final _animatedPositionedKey = GlobalKey<_AnimatedPositionedExampleState>();

  static const Duration duration = Duration(seconds: 2);
  static const Curve curve = Curves.fastOutSlowIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Animated Position'),
        ),
        body: Center(
          child: AnimatedPositionedExample(
            key: _animatedPositionedKey,
            duration: duration,
            curve: curve,
          ),
        ),
        floatingActionButton: Botones(
          onMovePressed: () {
            _animatedPositionedKey.currentState?.cambiarFormaYColor();
          },
        ),
      ),
    );
  }
}

class AnimatedPositionedExample extends StatefulWidget {
  const AnimatedPositionedExample({
    required this.duration,
    required this.curve,
    super.key,
  });

  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedPositionedExample> createState() =>
      _AnimatedPositionedExampleState();
}

class _AnimatedPositionedExampleState extends State<AnimatedPositionedExample> {
  double leftPosition = 10.0; // Posición inicial en el eje X
  double width = 100.0; // Ancho inicial del cuadrado
  double height = 100.0; // Altura inicial del cuadrado
  Color color = Colors.blue; // Color inicial del cuadrado

  final Random random = Random();

  void cambiarFormaYColor() {
    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      width = random.nextDouble() * 150 + 50;
      height = random.nextDouble() * 150 + 50;

      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      if (leftPosition + width >= screenWidth) {
        leftPosition = 10.0;
      } else {
        leftPosition += 100.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      height: 350,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            left: leftPosition,
            top: 150.0,
            width: width,
            height: height,
            duration: widget.duration,
            curve: widget.curve,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Botones extends StatelessWidget {
  final VoidCallback onMovePressed;

  const Botones({
    super.key,
    required this.onMovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: onMovePressed,
          child: const Icon(Icons.shuffle),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyApp(),
              ),
            );
          },
          child: const Icon(Icons.arrow_circle_left_outlined),
          backgroundColor: const Color.fromARGB(244, 46, 150, 185),
        ),
      ],
    );
  }
}
