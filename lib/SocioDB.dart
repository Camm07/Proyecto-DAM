import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_dam/socio.dart';

class SocioDB {
  static FirebaseFirestore db = FirebaseFirestore.instance;

  // Agregar un nuevo socio a la base de datos
  static Future<DocumentReference> agregarSocio(Socio socio) async {
    return await db.collection("Socios").add(socio.toMap());
  }

  // Obtener todos los socios desde la base de datos
  static Future<List<Socio>> obtenerSocios() async {
    QuerySnapshot querySnapshot = await db.collection("Socios").get();
    return querySnapshot.docs.map((doc) => Socio.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  // Actualizar la información de un socio existente
  static Future<void> actualizarSocio(Socio socio) async {
    await db.collection("Socios").doc(socio.id).update(socio.toMap());
  }

  // Cambiar el estado de un socio a "inactivo" en lugar de eliminarlo
  static Future<void> cambiarEstadoSocio(String id, String nuevoEstado) async {
    await db.collection("Socios").doc(id).update({'status': nuevoEstado});
  }

  static Stream<QuerySnapshot> obtenerSociosStream() {
    return db.collection("Socios").snapshots();
  }

  static Future<Socio?> obtenerSocioActual() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid; // UID del usuario actual de Firebase

    if (userId != null) {
      // Suponiendo que existe una colección 'usuarios' donde mapeas UID a ID de documento de socios
      var userDoc = await db.collection('usuarios').doc(userId).get();
      if (userDoc.exists) {
        String socioId = userDoc.data()?['socioId'];  // Asumimos que hay un campo 'socioId' que contiene el ID del documento de Socios
        var socioDoc = await db.collection('Socios').doc(socioId).get();
        if (socioDoc.exists) {
          return Socio.fromMap(socioDoc.data() as Map<String, dynamic>, socioDoc.id);
        }
      }
    }
    return null;  // Retorna null si no hay usuario logueado o no se encuentra el documento
  }

}
