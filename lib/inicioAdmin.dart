import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/registroSocios.dart';


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
        title: Text("ADMIN"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: (){},
              icon: Icon(Icons.access_time_outlined),
              color: Colors.black,
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
                  CircleAvatar(
                    child: Text("ITT",style: TextStyle(color: Colors.black),),radius: 30,backgroundColor: Colors.orangeAccent,),
                  Text("Tecnológico de Tepic",),
                  Text("(C) Derechos reservados",),
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xFFFFC107).withOpacity(0.6)
              ),
            ),
            SizedBox(height: 30,),
            itemDrawer(1,Icons.home,"Inicio",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(2,Icons.person,"Registrar Socios",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(3,Icons.person,"Listado de  Socios",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(4,Icons.email,"Solicitud",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(5,Icons.calendar_month,"Reservacion",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(6,Icons.output,"Cerrar Sesion",Colors.orangeAccent),
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
      case 4: return Solicitud();
      case 5: return Reservacion();
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
          Icon(icono, color: color),
          SizedBox(width: 10),
          Text(etiqueta, style: TextStyle(fontSize: 20)),
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



  Widget LSocios() {
    return Scaffold();
  }

  Widget Solicitud() {
    return Scaffold();
  }

  Widget Reservacion() {
    return Scaffold();
  }


}
