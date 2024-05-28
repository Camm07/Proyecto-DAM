import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/main.dart';
import 'package:proyecto_dam/perfilSocio.dart';
import 'package:proyecto_dam/reservacionSocio.dart';
import 'package:proyecto_dam/socio.dart';
import 'package:proyecto_dam/SocioDB.dart';
import 'package:proyecto_dam/solicitudSocio.dart';
import 'package:proyecto_dam/verSolicitudAdmin.dart';

class InicioSocio extends StatefulWidget {
  const InicioSocio({super.key});

  @override
  State<InicioSocio> createState() => _InicioSocioState();
}

class _InicioSocioState extends State<InicioSocio> {
  final List<String> imgList = [
    'assets/imagen1.jpeg',
    'assets/imagen2.jpeg',
    'assets/imagen3.jpeg',
    'assets/imagen4.jpeg'
  ];
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
        foregroundColor: Colors.white,
        title: Text("SOCIO", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,

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
            SizedBox(height: 30,),
            buildDrawerItem(Icons.home, "Inicio", 1),
            SizedBox(height: 20,),
            buildDrawerItem(Icons.person, "Perfil", 2),
            SizedBox(height: 20,),
            buildDrawerItem(Icons.email, "Solicitud", 3),
            SizedBox(height: 20,),
            buildDrawerItem(Icons.calendar_month, "Reservación", 4),
            SizedBox(height: 20,),
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
        return SolicitudSocio();
      case 4:
        return ReservacionSocio();  // Pantalla de reservaciones
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
      title: Expanded(child: Text(text,style: TextStyle(fontSize: 20),),flex: 2,),
    );
  }

  Widget Inicio() => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text('Bienvenido, ${socioActual?.nombre ?? "Socio"}', style: TextStyle(fontSize: 25,color: Colors.indigo),),
          SizedBox(height: 45),
          Text(
            'Explora las áreas exclusivas que tenemos para ti.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 30,),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
            ),
            items: imgList.map((item) => Container(
              child: Center(
                  child: Image.asset(item, fit: BoxFit.cover, width: 1000,height: 1100,)
              ),
            )).toList(),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'En el Club Deportivo, contamos con instalaciones de primera clase, incluyendo piscinas, canchas de tenis, gimnasios totalmente equipados y áreas de relajación. Explora, participa y disfruta de las diversas actividades y eventos que tenemos para ti.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '¡Ven y vive la experiencia!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );



  Widget SolicitudesS() => Center(child: Text('Página de Solicitudes'));

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
