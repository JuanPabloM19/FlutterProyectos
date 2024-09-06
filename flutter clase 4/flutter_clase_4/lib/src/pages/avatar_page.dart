import 'package:flutter/material.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Page'),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://media.istockphoto.com/id/1465504312/es/vector/avatar-de-joven-hombre-sonriente-hombre-con-barba-marr%C3%B3n-bigote-y-cabello-vestido-con-su%C3%A9ter.jpg?s=2048x2048&w=is&k=20&c=nrDNlapIfZ74kiucAABV1cTd4egVoWxHdnKzPmDDtcA=')),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: const CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text('FS'),
            ),
          )
        ],
      ),
      body: const Center(
        child: FadeInImage(
          image: NetworkImage(
              'https://media.istockphoto.com/id/1465504312/es/vector/avatar-de-joven-hombre-sonriente-hombre-con-barba-marr%C3%B3n-bigote-y-cabello-vestido-con-su%C3%A9ter.jpg?s=2048x2048&w=is&k=20&c=nrDNlapIfZ74kiucAABV1cTd4egVoWxHdnKzPmDDtcA='),
          placeholder: AssetImage('assets/jar-loading.gif'),
        ),
      ),
    );
  }
}
