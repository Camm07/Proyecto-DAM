import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';

class Socio extends StatefulWidget {
  const Socio({super.key});

  @override
  State<Socio> createState() => _SocioState();
}

class _SocioState extends State<Socio> {
  int _indice=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOCIO"),
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
            itemDrawer(2,Icons.person,"Perfil",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(3,Icons.email,"Solicitud",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(4,Icons.calendar_month,"Reservacion",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(5,Icons.output,"Cerrar Sesion",Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget pantallas() {
    switch(_indice){
      case 1: return Inicio();
      case 2: return Perfil();
      case 3: return Solicitud();
      case 4: return Reservacion();
      default:
        return Inicio();
    }
  }


  Widget itemDrawer(int indice, IconData icono, String etiqueta, Color color) {
    return ListTile(
      onTap: () {
        if (indice == 5) {
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

  Widget Perfil() {
    return Scaffold();
  }

  Widget Solicitud() {
    return Scaffold();
  }

  Widget Reservacion() {
    return Scaffold();
  }

  // Este método debería ser llamado desde algún lugar, por ejemplo, un botón en tu Drawer
  void Cerrar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar Sesión"),
        content: Text("¿Estás seguro de querer cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),  // Solo cierra el diálogo
            child: Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Autenticacion.cerrarSesion().then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyApp()),  // Asumiendo que MyApp es tu pantalla de inicio de sesión
                );
              });
            },
            child: Text("SI"),
          ),
        ],
      ),
    );
  }






}
