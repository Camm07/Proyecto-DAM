import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ServiciosFirebaseySQFlite.dart';
import 'package:proyecto_dam/solicitud.dart';

class SolicitudSocio extends StatefulWidget {
  @override
  _SolicitudSocioState createState() => _SolicitudSocioState();
}

class _SolicitudSocioState extends State<SolicitudSocio> {
  final TextEditingController _descripcionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text('Solicitud de cambios',style:TextStyle(color: Colors.indigo,fontSize: 25) ,),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Escriba su solicitud aquí',
                suffixIcon: Icon(Icons.wallet_rounded,color: Colors.indigo,)
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarSolicitud,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send,color: Colors.white,),
                  SizedBox(width: 8,),
                  Text('Enviar Solicitud'),
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
            SizedBox(height: 20),
            Expanded(
              child: _buildListaSolicitudes(),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarSolicitud() async {
    String? idSocio = await _obtenerIdSocioActual();
    if (idSocio == null) {
      _showMessage('Error: No se ha podido identificar al socio.');
      return;
    }

    if (_descripcionController.text.isEmpty) {
      _showMessage('Por favor, ingrese una descripción para la solicitud.');
      return;
    }

    Solicitud nuevaSolicitud = Solicitud(
      idSocio: idSocio,
      descripcion: _descripcionController.text,
      fechaHoraAtendida: DateTime.now(), // Usa la hora local para consistencia con tu sistema web
      estatus: 'Pendiente',
    );

    await _databaseService.addSolicitud(nuevaSolicitud);
    _descripcionController.clear();
    setState(() {});
    _showMessage('Solicitud enviada con éxito.');
  }

  Widget _buildListaSolicitudes() {
    return FutureBuilder<String?>(
      future: _obtenerIdSocioActual(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No se pudo obtener el ID del socio.'));
        }
        return StreamBuilder<QuerySnapshot>(
          stream: _databaseService.getSolicitudesStream(snapshot.data!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            var docs = snapshot.data!.docs;
            return ListView(
              children: docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                DateTime fechaHora = data['Fecha_Hora_Atendida'] is Timestamp
                    ? (data['Fecha_Hora_Atendida'] as Timestamp).toDate()
                    : DateTime.parse(data['Fecha_Hora_Atendida']);
                return ListTile(
                  title: Text(data['Descripcion']),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaHora)),
                  trailing: Text(data['Estatus']),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _obtenerIdSocioActual() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('socioId');
  }
}
