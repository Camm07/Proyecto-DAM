import 'package:cloud_firestore/cloud_firestore.dart';

class Solicitud {
  String id;
  final String idSocio;
  final String descripcion;
  DateTime fechaHoraAtendida;
  final String estatus;
  final String comentario;

  Solicitud({
    this.id = '',
    required this.idSocio,
    required this.descripcion,
    required this.fechaHoraAtendida,
    this.estatus = "Pendiente",
    this.comentario = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'Id_Socio': idSocio,
      'Descripcion': descripcion,
      'Fecha_Hora_Atendida': Timestamp.fromDate(fechaHoraAtendida),
      'Estatus': estatus,
      'Comentario': comentario,
    };
  }

  factory Solicitud.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Solicitud(
      id: doc.id,
      idSocio: data['Id_Socio'] ?? '',
      descripcion: data['Descripcion'] ?? '',
      fechaHoraAtendida: data['Fecha_Hora_Atendida'] is Timestamp ? (data['Fecha_Hora_Atendida'] as Timestamp).toDate() : DateTime.parse(data['Fecha_Hora_Atendida']),
      estatus: data['Estatus'] ?? 'Pendiente',
      comentario: data['Comentario'] ?? '',
    );
  }

  factory Solicitud.fromMap(Map<String, dynamic> map, String id) {
    return Solicitud(
      id: id,
      idSocio: map['Id_Socio'] ?? '',
      descripcion: map['Descripcion'] ?? '',
      fechaHoraAtendida: DateTime.parse(map['Fecha_Hora_Atendida']),
      estatus: map['Estatus'] ?? 'Pendiente',
      comentario: map['Comentario'] ?? '',
    );
  }
}


