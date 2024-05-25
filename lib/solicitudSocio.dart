import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam/solicitud.dart';
import 'ServiciosFirebaseySQFlite.dart';

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
        title: Text('Solicitud del Socio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Describe su solicitud aquí',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarSolicitud,
              child: Text('Enviar Solicitud'),
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
    if (_descripcionController.text.isEmpty) {
      return;
    }

    Solicitud nuevaSolicitud = Solicitud(
      idSocio: 'dummy_idSocio',  // Aquí deberías usar el idSocio real del usuario
      descripcion: _descripcionController.text,
      fechaHoraAtendida: DateTime.now(),
      estatus: 'Pendiente',
    );

    await _databaseService.addSolicitud(nuevaSolicitud);

    _descripcionController.clear();

    setState(() {}); // Refrescar la lista
  }

  Widget _buildListaSolicitudes() {
    return FutureBuilder<List<Solicitud>>(
      future: _databaseService.getSolicitudes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<Solicitud> solicitudes = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Estatus')),
              DataColumn(label: Text('ID Solicitud')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Comentario')),
            ],
            rows: solicitudes.map((Solicitud solicitud) {
              return DataRow(
                cells: [
                  DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(solicitud.fechaHoraAtendida))),
                  DataCell(Text(solicitud.estatus)),
                  DataCell(Text(solicitud.id)),
                  DataCell(Text(solicitud.descripcion)),
                  DataCell(Text(solicitud.comentario)),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
