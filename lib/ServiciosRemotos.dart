import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Autenticacion {
  static FirebaseAuth autenticar = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<User?> autenticarUsuario(String email, String password) async {
    try {
      UserCredential usuario = await autenticar.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return usuario.user;
    } catch(e) {
      return null;
    }
  }

  static Future<String?> verificarRol(User? user) async {
    if (user != null) {
      var docUsuario = await db.collection('Usuario').doc(user.uid).get();
      if (docUsuario.exists && docUsuario.data()!['tipo'] == 'administrador') {
        return 'administrador';
      } else {
        var querySocio = await db.collection('Socios')
            .where('uid', isEqualTo: user.uid)
            .get();
        if (querySocio.docs.isNotEmpty && querySocio.docs.first.data()['status'] == 'Activo') {
          return 'socio';
        }
      }
    }
    return null;
  }

  static bool estaLogueado() {
    return autenticar.currentUser != null;
  }

  static Future<void> cerrarSesion() async {
    await autenticar.signOut();
  }
}
