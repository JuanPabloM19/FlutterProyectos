import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/providers/menu_provider.dart';
import 'package:flutter_application_1/src/utils/icono_string_util.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Componentes'),
      ),
      body: _lista(),
    );
  }

  Widget _lista() {
    return FutureBuilder(
      future: menuProvider.cargarData(),
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ListView(
          children: _listaItems(snapshot.data, context),
        );
      },
    );
  }

  List<Widget> _listaItems(List<dynamic> data, BuildContext context) {
    final List<Widget> opciones = [];
    data.forEach((opt) {
      final widgetTemp = ListTile(
        title: Text(opt['texto']),
        leading: getIcon(opt['icon']),
        trailing: Icon(
          Icons.arrow_forward_ios_outlined,
          color: Colors.blue,
        ),
        onTap: () {
//Se utiliza el objeto Navigator.pushNamed para generar las rutas a partir de los datos almacenados en el archivo JSON
          Navigator.pushNamed(context, opt['ruta']);
        },
      );
      opciones.add(widgetTemp);
      opciones.add(Divider());
    });
    return opciones;
  }
}
