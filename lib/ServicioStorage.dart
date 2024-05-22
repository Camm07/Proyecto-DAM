import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ServicioStorage {
  static final FirebaseStorage storage = FirebaseStorage.instance;

  /// Sube una imagen seleccionada desde la galería a Firebase Storage y retorna su URL
   Future<String?> subirImagen(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      String path = 'profileImages/$fileName';
      TaskSnapshot snapshot = await storage.ref(path).putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  /// Obtiene la URL de una imagen almacenada en Firebase Storage
   Future<String?> obtenerUrlImagen(String fileName) async {
    try {
      return await storage.ref('profileImages/$fileName').getDownloadURL();
    } catch (e) {
      print('Error al obtener URL de imagen: $e');
      return null;
    }
  }
}


