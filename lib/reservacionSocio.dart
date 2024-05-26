import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservacionSocio extends StatefulWidget {
  @override
  _ReservacionSocioState createState() => _ReservacionSocioState();
}

class _ReservacionSocioState extends State<ReservacionSocio> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _espacioController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text('Reservación del Socio',style: TextStyle(color: Colors.indigo,fontSize: 25),),
      ),
      body: SingleChildScrollView(
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
            DropdownButtonFormField<String>(
              value: null,
              items: <String>[
                'Cancha de tenis',
                'Salón de eventos',
                'Piscina'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Espacio a reservar'),
              onChanged: (String? newValue) {
                setState(() {
                  _espacioController.text = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _attemptReservation,
              child: Text("Reservar",style: TextStyle(color: Colors.white),),
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
      try {
        // Recuperar el ID del documento del socio de SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? socioId = prefs.getString('socioId');

        if (socioId == null) {
          _showMessage('Error al enviar la reserva: ID del Socio no disponible');
          return;
        }

        String espacio = _espacioController.text;
        DateTime fechaReservacion = DateTime.parse(_fechaController.text);

        // Convertir DateTime a una cadena en formato ISO para Firestore
        String fechaReservacionISO = DateFormat('yyyy-MM-dd').format(fechaReservacion);

        // Realizar la reserva con el ID del documento del socio
        await _firestore.collection('Coleccion_Reservacion').add({
          'Id_Socio': socioId,
          'Espacio': espacio,
          'Fecha_Reservacion': fechaReservacionISO,  // Guardar como cadena en formato ISO
          'Fecha_Hora_Solicitud': Timestamp.now(),
          'Comentario': "",
          'Estatus': "Pendiente",
        });
        _showMessage('Tu reserva fue enviada exitosamente.');
      } catch (error) {
        _showMessage('Error al enviar la reserva: $error');
      }
    } else {
      _showMessage('Por favor completa todos los campos requeridos.');
    }
  }





  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
