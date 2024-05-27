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
        foregroundColor: Colors.transparent,
        title: Text('Listado de Reservaciones',style: TextStyle(color: Colors.indigo,fontSize: 25),),
        centerTitle: true,
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
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('ID Reservación',style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Nombre Socio',style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Fecha de Reservación',style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Espacio',style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Estatus',style: TextStyle(color: Colors.indigo, fontSize: 17))),
                DataColumn(label: Text('Acciones',style: TextStyle(color: Colors.indigo, fontSize: 17))),
              ],
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                print('Procesando reservación: ${document.id} con Id_Socio: ${data['Id_Socio']}');
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                    return getStatusColor(data['Estatus']);
                  }),
                  cells: [
                    DataCell(Text(document.id)),
                    DataCell(FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('Socios').doc(data['Id_Socio']).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Cargando...');
                        }
                        if (snapshot.hasError) {
                          print('Error al obtener los datos del socio: ${snapshot.error}');
                          return Text('Error');
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          print('El documento del socio con ID ${data['Id_Socio']} no existe o no tiene datos');
                          return Text('Nombre no disponible');
                        }
                        var socioData = snapshot.data!.data() as Map<String, dynamic>;
                        if (socioData.containsKey('nombre') && socioData.containsKey('apellidos')) {
                          print('Datos del socio obtenidos: ${socioData['nombre']} ${socioData['apellidos']}');
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
                if (_commentController.text.isEmpty) {
                  Navigator.of(context).pop(); // Cierra el diálogo para mostrar el SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, escribe un comentario antes de aceptar."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _updateReservationStatus(
                      idReserva, 'Aprobada', _commentController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Rechazar'),
              onPressed: () {
                if (_commentController.text.isEmpty) {
                  Navigator.of(context).pop(); // Cierra el diálogo para mostrar el SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, escribe un comentario antes de rechazar."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _updateReservationStatus(
                      idReserva, 'Rechazada', _commentController.text);
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
