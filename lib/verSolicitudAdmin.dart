import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam/solicitud.dart';
import 'ServiciosFirebaseySQFlite.dart';

class VerSolicitudes extends StatefulWidget {
  @override
  _VerSolicitudesState createState() => _VerSolicitudesState();
}

class _VerSolicitudesState extends State<VerSolicitudes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  String _filtroEstatus = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Solicitudes'),
      ),
      body: Column(
        children: [
          _buildFiltroEstatus(),
          Expanded(
            child: _buildListaSolicitudes(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroEstatus() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text('Filtrar por estatus:'),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: _filtroEstatus,
            onChanged: (String? newValue) {
              setState(() {
                _filtroEstatus = newValue!;
              });
            },
            items: <String>['Todos', 'Pendiente', 'Aprobada', 'Rechazada']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListaSolicitudes() {
    Query query = _firestore.collection('Coleccion_Solicitud').orderBy('fechaHoraAtendida', descending: true);
    if (_filtroEstatus != 'Todos') {
      query = query.where('estatus', isEqualTo: _filtroEstatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error al cargar las solicitudes. Ver consola para más detalles.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('ID Solicitud')),
              DataColumn(label: Text('Nombre Socio')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Fecha/Hora')),
              DataColumn(label: Text('ID Socio')),
              DataColumn(label: Text('Estatus')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(Text(document.id)),
                  DataCell(Text(data['idSocio'])),
                  DataCell(Text(data['descripcion'])),
                  DataCell(Text(_formatDate(data['fechaHoraAtendida']))),
                  DataCell(Text(data['idSocio'])),
                  DataCell(Text(data['estatus'])),
                  DataCell(ElevatedButton(
                    onPressed: () {
                      _showAtenderDialog(context, document.id, data);
                    },
                    child: Text('Atender'),
                  )),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm').format(date.toDate());
    } else if (date is String) {
      return date; // Assuming date string is already formatted
    } else {
      return 'Fecha no disponible';
    }
  }

  void _showAtenderDialog(BuildContext context, String idSolicitud, Map<String, dynamic> data) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atendiendo solicitud:'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('ID Solicitud: $idSolicitud'),
              Text('ID Socio: ${data['idSocio']}'),
              Text('Descripción: ${data['descripcion']}'),
              Text('Fecha/Hora: ${_formatDate(data['fechaHoraAtendida'])}'),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Escribe un comentario'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                _updateSolicitudStatus(idSolicitud, 'Aprobada', _commentController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rechazar'),
              onPressed: () {
                _updateSolicitudStatus(idSolicitud, 'Rechazada', _commentController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateSolicitudStatus(String idSolicitud, String newStatus, String comment) async {
    try {
      // Actualizar en Firestore
      await _firestore.collection('Coleccion_Solicitud').doc(idSolicitud).update({
        'estatus': newStatus,
        'comentario': comment,
      });

      // Actualizar en SQLite
      final db = await _databaseService.database;
      await db.update(
        'Solicitudes',
        {
          'estatus': newStatus,
          'comentario': comment,
        },
        where: 'id = ?',
        whereArgs: [idSolicitud],
      );

      print('Solicitud actualizada correctamente.');
    } catch (e) {
      print('Error al actualizar la solicitud: $e');
    }
  }
}
