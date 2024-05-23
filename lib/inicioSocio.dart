import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/perfilSocio.dart';
import 'package:proyecto_dam/reservacionSocio.dart';
import 'package:proyecto_dam/socio.dart';
import 'package:proyecto_dam/SocioDB.dart';
import 'package:proyecto_dam/solicitudSocio.dart';

class InicioSocio extends StatefulWidget {
  const InicioSocio({super.key});

  @override
  State<InicioSocio> createState() => _InicioSocioState();
}

class _InicioSocioState extends State<InicioSocio> {
  int _indice = 1;
  Socio? socioActual;

  @override
  void initState() {
    super.initState();
    cargarDatosSocio();
  }

  Future<void> cargarDatosSocio() async {
    socioActual = await SocioDB.obtenerSocioActual();
    if (socioActual != null) {
      print("Socio cargado: ${socioActual?.nombre}"); // Añade esto para depuración
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOCIO", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.access_time_outlined),
              color: Colors.black,
              onPressed: () {},
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
              decoration: BoxDecoration(color: Colors.indigoAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(socioActual?.fotoPerfil ?? 'https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(socioActual?.nombre ?? 'Cargando...', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            buildDrawerItem(Icons.home, "Inicio", 1),
            buildDrawerItem(Icons.person, "Perfil", 2),
            buildDrawerItem(Icons.email, "Solicitud", 3),
            buildDrawerItem(Icons.calendar_month, "Reservación", 4),
            buildDrawerItem(Icons.output, "Cerrar Sesión", 5),
          ],
        ),
      ),
    );
  }

  Widget pantallas() {
    switch (_indice) {
      case 1:
        return Inicio();
      case 2:
        return socioActual != null ? PerfilSocio(socio: socioActual) : CircularProgressIndicator();
      case 3:
        return SolicitudesS();
      case 4:
        return ReservacionS();
      default:
        return Inicio();
    }
  }

  Widget buildDrawerItem(IconData icon, String text, int index) {
    return ListTile(
      onTap: () {
        if (index == 5) {
          mostrarDialogoCerrarSesion();
        } else {
          setState(() {
            _indice = index;
          });
          Navigator.pop(context);
        }
      },
      leading: Expanded(child: Icon(icon, color: Colors.indigoAccent),),
      title: Expanded(child: Text(text), flex: 2,),
    );
  }

  Widget Inicio() => Center(child: Text('Bienvenido, ${socioActual?.nombre ?? "Socio"}', style: TextStyle(fontSize: 24)));
  Widget Solicitud() => Center(child: Text('Página de Solicitudes'));
  Widget Reservacion() => Center(child: Text('Página de Reservaciones'));

  void mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar Sesión"),
        content: Text("¿Estás seguro de querer cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Autenticacion.cerrarSesion().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyApp()),
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

