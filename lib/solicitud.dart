class Solicitud {
  final String id;
  final String idSocio;
  final String descripcion;
  final DateTime fechaHoraAtendida;
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
      'idSocio': idSocio,
      'descripcion': descripcion,
      'fechaHoraAtendida': fechaHoraAtendida.toIso8601String(),
      'estatus': estatus,
      'comentario': comentario,
    };
  }

  factory Solicitud.fromMap(Map<String, dynamic> map, String id) {
    return Solicitud(
      id: id,
      idSocio: map['idSocio'],
      descripcion: map['descripcion'],
      fechaHoraAtendida: DateTime.parse(map['fechaHoraAtendida']),
      estatus: map['estatus'] ?? "Pendiente", // Valor por defecto en caso de que no esté definido
      comentario: map['comentario'] ?? "",
    );
  }
}
