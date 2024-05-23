import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam/ServiciosFirebaseySQFlite.dart';
import 'package:proyecto_dam/reservacion.dart';
  // Asumiendo que así has llamado al archivo que contiene DatabaseService y Reservacion

class ReservacionS extends StatefulWidget {
  @override
  _ReservacionSState createState() => _ReservacionSState();
}

class _ReservacionSState extends State<ReservacionS> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _espacioController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();  // Asegúrate que este servicio está bien configurado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacer una Reservación'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha de la Reservación',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    _fechaController.text = formattedDate;
                  });
                }
              },
            ),
            TextField(
              controller: _espacioController,
              decoration: InputDecoration(labelText: 'Espacio a reservar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _attemptReservation(),
              child: Text('Reservar'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attemptReservation() async {
    if (_fechaController.text.isNotEmpty && _espacioController.text.isNotEmpty) {
      Reservacion nuevaReservacion = Reservacion(
        idSocio: 'ID_DEL_SOCIO',  // Este ID debería ser obtenido dinámicamente o pasado al widget
        espacio: _espacioController.text,
        fechaReservacion: DateTime.parse(_fechaController.text),
        fechaHoraSolicitud: DateTime.now(),  // Fecha actual como fecha de solicitud
      );
      try {
        await _databaseService.addReservacion(nuevaReservacion);
        _showDialog('Reservación Exitosa', 'Tu reservación ha sido guardada con éxito.');
        _fechaController.clear();
        _espacioController.clear();
      } catch (e) {
        _showDialog('Error', 'Hubo un problema al guardar tu reservación.');
      }
    } else {
      _showDialog('Error', 'Por favor completa todos los campos requeridos.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

