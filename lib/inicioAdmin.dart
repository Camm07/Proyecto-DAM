import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/registroSocios.dart';
import 'package:proyecto_dam/verReservacionesAdmin.dart';
import 'package:proyecto_dam/verSocios.dart';
import 'package:proyecto_dam/verSolicitudAdmin.dart';


class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _AdminState();
}

class _AdminState extends State<InicioAdmin> {
  int _indice=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Bienvenido Admin",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: (){},
              icon: Icon(Icons.access_time_outlined),
              color: Colors.white,
            ),
          )
        ],
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
            itemDrawer(5,Icons.calendar_month,"Reservacion",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(6,Icons.output,"Cerrar Sesion",Colors.indigoAccent),
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
    return Scaffold();
  }





  Widget Solicitud() {
    return Scaffold();
  }

  Widget Reservacion() {
    return Scaffold();
  }


}
