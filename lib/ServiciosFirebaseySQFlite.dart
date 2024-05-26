import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_dam/reservacion.dart';
import 'package:proyecto_dam/solicitud.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'club_del_valle.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE Reservaciones ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'idSocio TEXT,'
              'espacio TEXT,'
              'fechaReservacion TEXT,'
              'fechaHoraSolicitud TEXT,'
              'estatus TEXT DEFAULT "Pendiente",'
              'comentario TEXT DEFAULT ""'
              ');'
      );
      await db.execute(
          'CREATE TABLE Solicitudes ('
              'id TEXT PRIMARY KEY,'
              'idSocio TEXT,'
              'descripcion TEXT,'
              'fechaHoraAtendida TEXT,'
              'estatus TEXT DEFAULT "Pendiente",'
              'comentario TEXT DEFAULT ""'
              ');'
      );
    });
  }

  Future<void> addSolicitud(Solicitud solicitud) async {
    try {
      DocumentReference docRef = await firestore.collection('Coleccion_Solicitud').add(solicitud.toMap());
      solicitud.id = docRef.id;
      await addSolicitudToLocalDB(solicitud);
    } catch (e) {
      print('Error al agregar solicitud a Firestore: $e');
    }
  }

  Future<void> addSolicitudToLocalDB(Solicitud solicitud) async {
    final db = await database;
    await db.insert('Solicitudes', solicitud.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Stream<QuerySnapshot> getSolicitudesStream(String idSocio) {
    return firestore.collection('Coleccion_Solicitud')
        .where('Id_Socio', isEqualTo: idSocio)
        .snapshots();
  }

  Future<void> updateSolicitud(Solicitud solicitud) async {
    try {
      await firestore.collection('Coleccion_Solicitud').doc(solicitud.id).update(solicitud.toMap());
      final db = await database;
      await db.update(
        'Solicitudes',
        solicitud.toMap(),
        where: 'id = ?',
        whereArgs: [solicitud.id],
      );
    } catch (e) {
      print('Error al actualizar la solicitud: $e');
    }
  }
}
