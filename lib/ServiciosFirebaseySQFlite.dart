import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_dam/reservacion.dart';
import 'package:proyecto_dam/solicitud.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  static Database? _database;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Inicializar la base de datos SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'club_del_valle.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE Reservaciones (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idSocio TEXT,
          espacio TEXT,
          fechaReservacion TEXT,
          fechaHoraSolicitud TEXT,
          estatus TEXT DEFAULT 'Pendiente',
          comentario TEXT DEFAULT ''
        );
      ''');
      await db.execute('''
        CREATE TABLE Solicitudes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idSocio TEXT,
          descripcion TEXT,
          fechaHoraAtendida TEXT,
          estatus TEXT DEFAULT 'Pendiente',
          comentario TEXT DEFAULT ''
        );
      ''');
    });
  }

  Future<void> addReservacion(Reservacion reservacion) async {
    await addReservacionToFirestore(reservacion);
    await addReservacionToLocalDB(reservacion);
  }

  Future<void> addSolicitud(Solicitud solicitud) async {
    await addSolicitudToFirestore(solicitud);
    await addSolicitudToLocalDB(solicitud);
  }

  Future<void> addReservacionToFirestore(Reservacion reservacion) async {
    await firestore.collection('Coleccion_Reservacion').add(reservacion.toMap());
  }

  Future<void> addReservacionToLocalDB(Reservacion reservacion) async {
    final db = await database;
    await db.insert('Reservaciones', reservacion.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addSolicitudToFirestore(Solicitud solicitud) async {
    await firestore.collection('Coleccion_Solicitud').add(solicitud.toMap());
  }

  Future<void> addSolicitudToLocalDB(Solicitud solicitud) async {
    final db = await database;
    await db.insert('Solicitudes', solicitud.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Solicitud>> getSolicitudes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Solicitudes');

    return List.generate(maps.length, (i) {
      return Solicitud.fromMap(maps[i], maps[i]['id'].toString());
    });
  }
}
