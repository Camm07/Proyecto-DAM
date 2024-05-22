import 'package:cloud_firestore/cloud_firestore.dart';

class Socio {
  String id;
  String nombre;
  String apellidos;
  String correo;
  String telefono;
  String fotoPerfil;
  String status;
  String uid;  // Campo UID para identificar unívocamente al socio

  // Constructor de la clase Socio con parámetros requeridos y opcionales
  Socio({
    this.id = '',  // ID opcional, útil cuando se recupera un socio existente de Firestore
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fotoPerfil,
    required this.status,
    required this.uid,
  });

  // Método para convertir un objeto Socio a un mapa, útil para operaciones de Firestore
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

  // Fábrica para crear un objeto Socio desde un mapa, típicamente utilizado al recuperar datos de Firestore
  factory Socio.fromMap(Map<String, dynamic> map, String id) {
    return Socio(
      id: id,
      nombre: map['nombre'],
      apellidos: map['apellidos'],
      correo: map['correo'],
      telefono: map['telefono'],
      fotoPerfil: map['fotoPerfil'] ?? '',  // Usa un valor por defecto si fotoPerfil es null
      status: map['status'],
      uid: map['uid'],
    );
  }
}
