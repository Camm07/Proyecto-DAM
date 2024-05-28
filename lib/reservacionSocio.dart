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
        title: Text('Reservación de Espacio',style: TextStyle(color: Colors.indigo,fontSize: 25),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha de la Reservación',
                suffixIcon: Icon(Icons.calendar_today,color: Colors.indigo,),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.date_range_rounded),
                  SizedBox(width: 8,),
                  Text("Reservar",style: TextStyle(color: Colors.white,fontSize: 17),),
                ],
              ),
              style: ButtonStyle(

                backgroundColor: MaterialStateProperty.all(Colors.indigo), // Establece el color de fondo a índigo
                foregroundColor: MaterialStateProperty.all(Colors.white), // Establece el color del texto a blanco
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Añade bordes redondeados al botón
                    )
                ),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0)), // Añade padding interno
              ),
            ),
            SizedBox(height:30),
            _buildReservacionesList(),
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

        // Limpieza después de enviar la reserva
        _fechaController.clear();
        _showMessage('Tu reserva fue enviada exitosamente.');

      } catch (error) {
        _showMessage('Error al enviar la reserva: $error');
      }
    } else {
      _showMessage('Por favor completa todos los campos requeridos.');
    }
  }

  Widget _buildReservacionesList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: FutureBuilder<String?>(
        future: obtenerIdSocioActual(),
        builder: (context, snapshotId) {
          if (!snapshotId.hasData) {
            return Center(child: Text('Cargando...'));
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Coleccion_Reservacion')
                .where('Id_Socio', isEqualTo: snapshotId.data)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(child: Text('No hay reservaciones disponibles.'));
              }
              return ListView(
                shrinkWrap: true,
                children: docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['Espacio'], style: TextStyle(fontSize: 16)),
                    subtitle: Text(_formatDate(data['Fecha_Reservacion']), style: TextStyle(fontSize: 16)),
                    trailing: Text(data['Estatus'], style: TextStyle(fontSize: 16, color: getColorForStatus(data['Estatus']))),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Color getColorForStatus(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.blue;  // Color azul para pendiente
      case 'Aprobada':
        return Colors.green;  // Color verde para aprobada
      case 'Rechazada':
        return Colors.red;  // Color rojo para rechazada
      default:
        return Colors.black;  // Un color por defecto si no se reconoce el estatus
    }
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else if (date is String) {
      return date; // Assuming date string is already formatted
    } else {
      return 'Fecha no disponible';
    }
  }
  Future<String?> obtenerIdSocioActual() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? socioId = prefs.getString('socioId');
    return socioId;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
