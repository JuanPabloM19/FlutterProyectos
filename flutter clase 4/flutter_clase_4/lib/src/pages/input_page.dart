import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});
  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String _nombre = '';
  String _email = '';
  String _fecha = '';
  //Elementos del dropdown
  final List<String> _profesiones = [
    'Sin dato',
    'Contador',
    'Abogado',
    'Ingeniero',
    'Periodista',
    'Programador'
  ];
  //Opción que se selecciona en el dropdown
  String _opcionSeleccionadaDropdown = 'Sin dato';
  final TextEditingController _inputFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inputs'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        children: [
          _crearInput(),
          const Divider(),
          _crearEmail(),
          const Divider(),
          _crearPassword(),
          const Divider(),
          _crearFecha(context),
          const Divider(),
          _crearDropdown(),
          const Divider(),
          _crearPersona()
        ],
      ),
    );
  }

  Widget _crearInput() {
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          counter: Text('Letras ${_nombre.length}'),
          hintText: 'Nombre de la persona',
          labelText: 'Nombre',
          helperText: 'Solo nombre',
          suffixIcon: const Icon(Icons.accessibility),
          icon: const Icon(Icons.account_circle)),
      onChanged: (valor) {
        setState(() {
          _nombre = valor;
        });
      },
    );
  }

//Widget para generar un inputs para email
  Widget _crearEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Email',
          labelText: 'Email',
          suffixIcon: const Icon(Icons.alternate_email),
          icon: const Icon(Icons.email)),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
    );
  }

//Widget para generar un inputs para password
  Widget _crearPassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Password',
          labelText: 'Password',
          suffixIcon: const Icon(Icons.lock_open),
          icon: const Icon(Icons.lock)),
      onChanged: (valor) {
        setState(() {});
      },
    );
  }

//Widget para generar un inputs para seleccionar una fecha
  Widget _crearFecha(BuildContext context) {
    return TextField(
      enableInteractiveSelection: false,
      controller: _inputFieldController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Fecha de nacimiento',
          labelText: 'Fecha de nacimiento',
          suffixIcon: const Icon(Icons.perm_contact_calendar),
          icon: const Icon(Icons.calendar_today)),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context);
      },
    );
  }

//Widget para lanzar un modal con el calendario para seleccionar fecha
  _selectDate(BuildContext context) async {
    DateTime? calendario = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: const Locale('es', 'ES'));
    if (calendario != null) {
      setState(() {
        _fecha = calendario.toString();
        _inputFieldController.text = _fecha;
      });
    }
  }

//Se genera la lista de elementos para el dropdown
  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var profesion in _profesiones) {
      lista.add(DropdownMenuItem(
        value: profesion,
        child: Text(profesion),
      ));
    }
    return lista;
  }

//Widget para generar un dropdown
  Widget _crearDropdown() {
    return Row(
      children: <Widget>[
        const Icon(Icons.select_all),
        const SizedBox(
          width: 30.0,
        ),
        Expanded(
            child: DropdownButton(
//Valor por defecto del dropdown
                value: _opcionSeleccionadaDropdown,
                items: getOpcionesDropdown(),
                onChanged: (opt) {
                  setState(() {
                    _opcionSeleccionadaDropdown = opt.toString();
                  });
                }))
      ],
    );
  }

  Widget _crearPersona() {
    return ListTile(
      title: Text('Nombre es: $_nombre'),
      subtitle: Text('Email: $_email'),
      trailing: Text(_opcionSeleccionadaDropdown),
    );
  }
}
