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
        foregroundColor: Colors.transparent,
        title: Text('Listado de Solicitudes',style: TextStyle(color: Colors.indigo,fontSize: 25),),
        centerTitle: true,
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
          Text('Filtrar por estatus:',style: TextStyle(fontSize: 18),),
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
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('ID Solicitud', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Nombre Socio', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Descripción', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Fecha/Hora', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('ID Socio', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Estatus', style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.indigo, fontSize: 17))),
              ],
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                    return getStatusColor(data['Estatus']);
                  }),
                  cells: [
                    DataCell(Text(document.id)),
                    DataCell(Text('${data['Nombre Socio']}')),
                    DataCell(Text(data['Descripcion'])),
                    DataCell(Text(_formatDate(data['Fecha_Hora_Atendida']))),
                    DataCell(Text(data['Id_Socio'])),
                    DataCell(Text(data['Estatus'])),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showAtenderDialog(context, document.id, data);
                      },
                      child: Text('Atender', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,  // Fondo azul índigo
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        );

      },
    );
  }

  Color? getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.yellow[200];  // Amarillo pastel
      case 'Aprobada':
        return Colors.green[200];  // Verde pastel
      case 'Rechazada':
        return Colors.red[200];  // Rojo pastel
      default:
        return null;  // Sin color
    }
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
                if (_commentController.text.isEmpty) {
                  Navigator.of(context).pop(); // Cierra el diálogo para mostrar el SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, escribe un comentario antes de aceptar."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  await _updateSolicitudStatus(idSolicitud, 'Aprobada', _commentController.text, data);
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Rechazar'),
              onPressed: () async {
                if (_commentController.text.isEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, escribe un comentario antes de rechazar."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  await _updateSolicitudStatus(idSolicitud, 'Rechazada', _commentController.text, data);
                  Navigator.of(context).pop();
                }
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
