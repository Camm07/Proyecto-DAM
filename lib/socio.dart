import 'package:cloud_firestore/cloud_firestore.dart';

class Socio {
  String id;
  String nombre;
  String apellidos;
  String correo;
  String telefono;
  String fotoPerfil;
  String status;
  String uid;

  Socio({
    this.id = '',
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fotoPerfil,
    required this.status,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'fotoPerfil': fotoPerfil,
      'status': status,
      'uid': uid,
    };
  }

  factory Socio.fromMap(Map<String, dynamic> map, String id) {
    return Socio(
      id: id,
      nombre: map['nombre'] ?? '',
      apellidos: map['apellidos'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      fotoPerfil: map['fotoPerfil'] ?? 'https://firebasestorage.googleapis.com/v0/b/proyecto-club-c2df1.appspot.com/o/socio.png?alt=media&token=b766c205-80ec-45c6-bc3b-d6aadbcbb010',
      status: map['status'] ?? 'Activo',  // Proporciona un valor por defecto para el estado si no está presente
      uid: map['uid'] ?? '',
    );
  }
}

