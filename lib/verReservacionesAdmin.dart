import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerReservaciones extends StatefulWidget {
  @override
  _VerReservacionesState createState() => _VerReservacionesState();
}

class _VerReservacionesState extends State<VerReservaciones> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroEstatus = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Reservaciones'),
      ),
      body: Column(
        children: [
          _buildFiltroEstatus(),
          Expanded(
            child: _buildListaReservaciones(),
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

  Widget _buildListaReservaciones() {
    Query query = _firestore.collection('Coleccion_Reservacion').orderBy('Fecha_Hora_Solicitud', descending: true);
    if (_filtroEstatus != 'Todos') {
      query = query.where('Estatus', isEqualTo: _filtroEstatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error al cargar las reservaciones. Ver consola para más detalles.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('ID Reservación')),
              DataColumn(label: Text('Nombre Socio')),
              DataColumn(label: Text('Fecha de Reservación')),
              DataColumn(label: Text('Espacio')),
              DataColumn(label: Text('Estatus')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              print('Procesando reservación: ${document.id} con Id_Socio: ${data['Id_Socio']}');
              return DataRow(
                cells: [
                  DataCell(Text(document.id)),
                  DataCell(FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('Socios').where('uid', isEqualTo: data['Id_Socio']).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Cargando...');
                      }
                      if (snapshot.hasError) {
                        print('Error al obtener los datos del socio: ${snapshot.error}');
                        return Text('Error');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        print('El documento del socio con ID ${data['Id_Socio']} no existe o no tiene datos');
                        return Text('Nombre no disponible');
                      }
                      var socioData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      if (socioData.containsKey('nombre') && socioData.containsKey('apellidos')) {
                        return Text('${socioData['nombre']} ${socioData['apellidos']}');
                      } else {
                        print('El documento del socio no tiene los campos "nombre" o "apellidos"');
                        return Text('Nombre no disponible');
                      }
                    },
                  )),
                  DataCell(Text(_formatDate(data['Fecha_Reservacion']))),
                  DataCell(Text(data['Espacio'])),
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
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else if (date is String) {
      return date; // Assuming date string is already formatted
    } else {
      return 'Fecha no disponible';
    }
  }

  void _showAtenderDialog(BuildContext context, String idReserva, Map<String, dynamic> data) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atendiendo reserva:'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('ID Reserva: $idReserva'),
              Text('ID Socio: ${data['Id_Socio']}'),
              Text('Nombre: ${data['Nombre'] ?? 'Nombre no disponible'}'),
              Text('Fecha de Reservación: ${_formatDate(data['Fecha_Reservacion'])}'),
              Text('Fecha de Solicitud: ${_formatDate(data['Fecha_Hora_Solicitud'])}'),
              Text('Espacio: ${data['Espacio']}'),
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
                _updateReservationStatus(idReserva, 'Aprobada', _commentController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Rechazar'),
              onPressed: () {
                _updateReservationStatus(idReserva, 'Rechazada', _commentController.text);
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

  void _updateReservationStatus(String idReserva, String newStatus, String comment) async {
    try {
      await _firestore.collection('Coleccion_Reservacion').doc(idReserva).update({
        'Estatus': newStatus,
        'Comentario': comment,
      });
      print('Reservación actualizada correctamente.');
    } catch (e) {
      print('Error al actualizar la reservación: $e');
    }
  }
}
