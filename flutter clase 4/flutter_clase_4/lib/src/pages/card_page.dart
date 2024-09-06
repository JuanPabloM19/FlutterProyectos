import 'package:flutter/material.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          _cardTipo1(),
          const SizedBox(
            height: 30.0,
          ),
          _cardTipo2(),
          const SizedBox(
            height: 30.0,
          ),
          _cardTipo3(),
        ],
      ),
    );
  }

  Widget _cardTipo1() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.photo_album,
              color: Colors.blue,
            ),
            title: Text('Título de la Tarjeta'),
            subtitle: Text(
                'Este texto forma parte del cuerpo de la tarjeta. Puede contener texto que describa el comportamiento de la misma'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {},
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardTipo2() {
    return Card(
      child: Column(
        children: <Widget>[
          const FadeInImage(
            placeholder: AssetImage('assets/jar-loading.gif'),
            image: NetworkImage(
                'https://i.natgeofe.com/n/2a832501-483e-422f-985c-0e93757b7d84/6_3x2.jpg'),
            fadeInDuration: Duration(milliseconds: 200),
            height: 300.0,
            fit: BoxFit.cover,
          ),
          Container(
              padding: const EdgeInsets.all(10.0),
              child: const Text('Descripción de la imagen de tarjeta'))
        ],
      ),
    );
  }

  Widget _cardTipo3() {
    final card = Column(
      children: <Widget>[
        const FadeInImage(
          placeholder: AssetImage('assets/jar-loading.gif'),
          image: NetworkImage(
              'https://i.natgeofe.com/n/2a832501-483e-422f-985c-0e93757b7d84/6_3x2.jpg'),
          fadeInDuration: Duration(milliseconds: 400),
          fit: BoxFit.cover,
        ),
        Container(
            padding: const EdgeInsets.all(10.0),
            child: const Text('Contenedor con aspecto de Tarjeta'))
      ],
    );
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 8.0)),
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: card,
      ),
    );
  }
}
