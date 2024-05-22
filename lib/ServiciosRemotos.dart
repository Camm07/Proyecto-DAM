import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Autenticacion {
  static FirebaseAuth autenticar = FirebaseAuth.instance;
  static FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<User?> autenticarUsuario(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      UserCredential usuario = await autenticar.signInWithEmailAndPassword(email: email, password: password);
      User? user = usuario.user;

      if (user != null) {
        var docUsuario = await db.collection('Usuario').doc(user.uid).get();
        if (docUsuario.exists && docUsuario.data()!['tipo'] == 'administrador') {
          await prefs.setString('userRole', 'administrador');
          await prefs.setString('userId', user.uid);
          return user;
        } else {
          var querySocio = await db.collection('Socios').where('uid', isEqualTo: user.uid).get();
          if (querySocio.docs.isNotEmpty) {
            var socio = querySocio.docs.first;
            if (socio.data()['status'] == 'Activo') {
              await prefs.setString('userRole', 'socio');
              await prefs.setString('socioId', socio.id); // Guardar ID del documento del socio
              return user;
            }
          }
        }
      }
    } catch (e) {
      print('Error de autenticación: $e');
    }
    return null;
  }

  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await autenticar.signOut();
  }

  static Future<String?> obtenerRol() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  static Future<String?> obtenerSocioId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('socioId');
  }
}


