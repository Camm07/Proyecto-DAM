class Reservacion {
  final String id;
  final String idSocio;
  final String espacio;
  final DateTime fechaReservacion;
  final DateTime fechaHoraSolicitud;  // Campo nuevo para fecha y hora de la solicitud
  final String estatus;
  final String comentario;

  Reservacion({
    this.id = '',
    required this.idSocio,
    required this.espacio,
    required this.fechaReservacion,
    required this.fechaHoraSolicitud,  // Requerido o proporcionar un valor por defecto
    this.estatus = "Pendiente",
    this.comentario = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'idSocio': idSocio,
      'espacio': espacio,
      'fechaReservacion': fechaReservacion.toIso8601String(),
      'fechaHoraSolicitud': fechaHoraSolicitud.toIso8601String(), // Guardar como string ISO
      'estatus': estatus,
      'comentario': comentario,
    };
  }

  factory Reservacion.fromMap(Map<String, dynamic> map, String id) {
    return Reservacion(
      id: id,
      idSocio: map['idSocio'],
      espacio: map['espacio'],
      fechaReservacion: DateTime.parse(map['fechaReservacion']),
      fechaHoraSolicitud: DateTime.parse(map['fechaHoraSolicitud']),  // Parsear la fecha de solicitud
      estatus: map['estatus'],
      comentario: map['comentario'],
    );
  }
}

