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
    Query query = _firestore.collection('Coleccion_Solicitud').orderBy('Fecha_Hora_Atendida', descending: true);
    if (_filtroEstatus != 'Todos') {
      query = query.where('Estatus', isEqualTo: _filtroEstatus);
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
                  DataCell(FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('Socios').doc(data['Id_Socio']).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Cargando...');
                      }
                      if (snapshot.hasError) {
                        return Text('Error');
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('Nombre no disponible');
                      }
                      var socioData = snapshot.data!.data() as Map<String, dynamic>;
                      return Text('${socioData['nombre']} ${socioData['apellidos']}');
                    },
                  )),
                  DataCell(Text(data['Descripcion'])),
                  DataCell(Text(_formatDate(data['Fecha_Hora_Atendida']))),
                  DataCell(Text(data['Id_Socio'])),
                  DataCell(Text(data['Estatus'])),
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
              Text('ID Socio: ${data['Id_Socio']}'),
              Text('Descripción: ${data['Descripcion']}'),
              Text('Fecha/Hora: ${_formatDate(data['Fecha_Hora_Atendida'])}'),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Escribe un comentario'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                await _updateSolicitudStatus(idSolicitud, 'Aprobada', _commentController.text, data);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rechazar'),
              onPressed: () async {
                await _updateSolicitudStatus(idSolicitud, 'Rechazada', _commentController.text, data);
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

  Future<void> _updateSolicitudStatus(String idSolicitud, String newStatus, String comment, Map<String, dynamic> data) async {
    try {
      Solicitud solicitud = Solicitud(
        id: idSolicitud,
        idSocio: data['Id_Socio'],
        descripcion: data['Descripcion'],
        fechaHoraAtendida: DateTime.now(),
        estatus: newStatus,
        comentario: comment,
      );

      await _databaseService.updateSolicitud(solicitud);
      setState(() {}); // Refrescar la lista
      print('Solicitud actualizada correctamente.');
    } catch (e) {
      print('Error al actualizar la solicitud: $e');
    }
  }
}
