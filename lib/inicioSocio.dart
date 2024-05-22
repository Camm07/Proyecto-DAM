import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/socio.dart';

class InicioSocio extends StatefulWidget {
  const InicioSocio({super.key});

  @override
  State<InicioSocio> createState() => _SocioState();
}

class _SocioState extends State<InicioSocio> {
  int _indice=1;
  Socio? socio;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOCIO",style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
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
                    CircleAvatar( backgroundImage: NetworkImage((socio?.fotoPerfil ?? 'https://via.placeholder.com/150'))),
                      Text(socio?.nombre ?? 'Nombre del Socio', style: TextStyle(color: Colors.white)),
                      Text("(C) Derechos reservados",style: TextStyle(color: Colors.white)),
                  ],
                ),
              decoration: BoxDecoration(
                color:Colors.indigoAccent
              ),
            ),
            SizedBox(height: 30,),
            itemDrawer(1,Icons.home,"Inicio",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(2,Icons.person,"Perfil",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(3,Icons.email,"Solicitud",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(4,Icons.calendar_month,"Reservación",Colors.indigoAccent),
            SizedBox(height: 20,),
            itemDrawer(5,Icons.output,"Cerrar Sesión",Colors.indigoAccent),
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
          Expanded(child: Icon(icono, color: color)),
          SizedBox(width: 10),
          Expanded(child: Text(etiqueta, style: TextStyle(fontSize: 20),),flex: 2,),
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








}
