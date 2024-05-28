import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/registroSocios.dart';
import 'package:proyecto_dam/verReservacionesAdmin.dart';
import 'package:proyecto_dam/verSocios.dart';
import 'package:proyecto_dam/verSolicitudAdmin.dart';

import 'ServiciosFirebaseySQFlite.dart';


class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _AdminState();
}

class _AdminState extends State<InicioAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  int _indice=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Bienvenido Administrador",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.indigo,

      ),
      body: pantallas(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(  child:Image.asset("assets/logoclub.png") ),
                  Text("Club Deportivo del Valle",style: TextStyle(color: Colors.white),),
                  Text("(C) Derechos reservados",style: TextStyle(color: Colors.white)),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.indigo
              ),
            ),
            SizedBox(height: 30,),
            itemDrawer(1,Icons.home,"Inicio",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(2,Icons.person,"Registrar Socios",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(3,Icons.list_alt_outlined,"Listado de  Socios",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(4,Icons.email,"Solicitud",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(5,Icons.calendar_month,"Reservación",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(6,Icons.output,"Cerrar Sesión",Colors.indigoAccent),
          ],
        ),
      ),
    );
  }

  Widget pantallas() {
    switch(_indice){
      case 1: return Inicio();
      case 2: return RSocios();
      case 3: return LSocios();
      case 4: return VerSolicitudes();
      case 5: return VerReservaciones();
      default:
        return Inicio();
    }
  }

  Widget itemDrawer(int indice, IconData icono, String etiqueta, Color color) {
    return ListTile(
      onTap: () {
        if (indice == 6) {
          mostrarDialogoCerrarSesion();
        } else {
          setState(() {
            _indice = indice;
          });
          Navigator.pop(context);
        }
      },
      title: Row(
        children: [
          Expanded(child: Icon(icono, color: color)),
          SizedBox(width: 10),
          Expanded(child: Text(etiqueta, style: TextStyle(fontSize: 20)),flex: 2,),
        ],
      ),
    );
  }

  void mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar Sesión"),
        content: Text("¿Estás seguro de querer cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
            child: Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Autenticacion.cerrarSesion().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyApp()), // Asume que MyApp es tu pantalla de inicio de sesión
                );
              });
            },
            child: Text("SI"),
          ),
        ],
      ),
    );
  }

  Widget Inicio() {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text("Solicitudes pendientes",style: TextStyle(color: Colors.indigo,fontSize: 28),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildPendingRequests()),
        ],
      ),
    );

  }


  Widget _buildPendingRequests() {
    DateTime now = DateTime.now();
    DateTime startToday = DateTime(now.year, now.month, now.day);
    DateTime endToday = DateTime(now.year, now.month, now.day + 1).subtract(Duration(seconds: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Coleccion_Solicitud')
          .where('Estatus', isEqualTo: 'Pendiente')
          .where('Fecha_Hora_Atendida', isGreaterThanOrEqualTo: startToday)
          .where('Fecha_Hora_Atendida', isLessThanOrEqualTo: endToday)
          .orderBy('Fecha_Hora_Atendida', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar las solicitudes: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data != null && snapshot.data!.docs.isEmpty) {
          // No hay solicitudes pendientes
          return Center(child:  Text("No hay solicitudes nuevas",style: TextStyle(color: Colors.teal,fontSize: 25),));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('Socios').doc(data['Id_Socio']).get(),
              builder: (context, socioSnapshot) {
                if (socioSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Cargando nombre...'));
                }
                if (socioSnapshot.hasError) {
                  return ListTile(title: Text('Error al obtener datos del socio'));
                }
                if (!socioSnapshot.hasData || !socioSnapshot.data!.exists) {
                  return ListTile(title: Text('Nombre no disponible'));
                }
                Map<String, dynamic> socioData = socioSnapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  tileColor: Colors.lightBlue[50],
                  title: Text(socioData['nombre'] ?? 'Nombre no disponible',style: TextStyle(fontSize: 17),),
                  subtitle: Text(data['Descripcion'] ?? 'Descripción no disponible',style: TextStyle(fontSize: 16)),
                  trailing: Text(_formatDate(data['Fecha_Hora_Atendida'],),style: TextStyle(fontSize: 16)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }




  String _formatDate(Timestamp date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date.toDate());
  }

}
