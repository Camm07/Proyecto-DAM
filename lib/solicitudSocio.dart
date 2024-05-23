import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam/ServiciosFirebaseySQFlite.dart';
import 'package:proyecto_dam/solicitud.dart';  // Asumiendo que tienes un modelo de datos para solicitudes

class SolicitudesS extends StatefulWidget {
  @override
  _SolicitudesSState createState() => _SolicitudesSState();
}

class _SolicitudesSState extends State<SolicitudesS> {
  final TextEditingController _descripcionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();  // Asegúrate que este servicio está bien configurado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text('Enviar Solicitud',style: TextStyle(color: Colors.indigo),),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción de la Solicitud',
                suffixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _attemptSendSolicitud(),
              child: Text('Enviar Solicitud'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: _buildSolicitudesList(),
            ),
          ],
        ),
      ),
    );
  }

  void _attemptSendSolicitud() async {
    if (_descripcionController.text.isNotEmpty) {
      Solicitud nuevaSolicitud = Solicitud(
        idSocio: 'ID_DEL_SOCIO',  // Este ID debería ser obtenido dinámicamente o pasado al widget
        descripcion: _descripcionController.text,
        fechaHoraAtendida: DateTime.now(),  // Fecha actual como fecha de solicitud
      );
      try {
        await _databaseService.addSolicitud(nuevaSolicitud);
        _showDialog('Solicitud Enviada', 'Tu solicitud ha sido enviada con éxito.');
        _descripcionController.clear();
      } catch (e) {
        _showDialog('Error', 'Hubo un problema al enviar tu solicitud.');
      }
    } else {
      _showDialog('Error', 'Por favor completa el campo de descripción.');
    }
  }

  Widget _buildSolicitudesList() {
    // Este método debería implementarse para mostrar la lista de solicitudes existentes
    // Similar al método utilizado en la página de reservaciones
    return Container();  // Placeholder para la implementación real
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
