import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/inicioAdmin.dart';
import 'package:proyecto_dam/inicioSocio.dart';
import 'package:proyecto_dam/reservacionSocio.dart';
import 'package:proyecto_dam/verReservacionesAdmin.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    routes: {
      '/admin': (context) => InicioAdmin(),
      '/socio': (context) => InicioSocio(),
      '/reservacion': (context) => ReservacionSocio(), //Nueva Ruta
      'ver_reservaciones': (context) => VerReservaciones(),
    },
  ));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  void handleLogin() async {
    var user = await Autenticacion.autenticarUsuario(email.text, password.text);
    if (user != null) {
      var rol = await Autenticacion.obtenerRol();  // Obtiene el rol directamente desde SharedPreferences
      switch (rol) {
        case 'administrador':
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'socio':
          Navigator.pushReplacementNamed(context, '/socio');
          break;
        default:
          mostrarErrorLogin();
          break;
      }
    } else {
      mostrarErrorLogin();
    }
  }

  void mostrarErrorLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error de autenticación. Por favor verifica tus credenciales."),
        backgroundColor: Colors.red,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade900, // Puedes ajustar estos colores
            Colors.cyan.shade600,  // para acercarte más al diseño que deseas
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          foregroundColor: Colors.transparent,
          title: Text(
            "Bienvenidxs",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  "CLUB DEPORTIVO DEL VALLE",
                  style: TextStyle(color: Colors.white,fontSize: 28),
                ),
                SizedBox(height: 10,),
                Image.asset("assets/logoclub.png",width: 350,height: 350,),
                SizedBox(height: 25,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => autenticar()),
                    );
                  },
                  child: Text("Iniciar Sesión",style: TextStyle(color: Colors.black,fontSize: 18),),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF64B5F6)), // Asumiendo un color teal
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )
                      )
                  ),
                ),
                SizedBox(height: 150,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos horizontalmente al centro
                  children: [
                    Icon(
                      Icons.location_on, // Icono de ubicación
                      color: Colors.white,
                    ),
                    SizedBox(width: 10), // Espacio horizontal entre el icono y el texto
                    Text(
                      "Av. del parque #45",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget autenticar() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Deportivo del Valle',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          Image.asset("assets/logoclub.png")
        ],
      ),
      body: Material( // Añadir el widget Material aquí
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Text("INICIAR SESIÓN", style: TextStyle(color: Colors.indigo, fontSize: 25)),
                SizedBox(height: 40),
                TextField(
                  controller: email,
                  decoration: InputDecoration(labelText: "Correo:",
                  suffixIcon: Icon(CupertinoIcons.person)),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Contraseña:",
                      suffixIcon: Icon(CupertinoIcons.padlock)),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: handleLogin,
                  child: Text("AUTENTICAR"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo), // Establece el color de fondo a índigo
                    foregroundColor: MaterialStateProperty.all(Colors.white), // Establece el color del texto a blanco
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Añade bordes redondeados al botón
                        )
                    ),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0)), // Añade padding interno
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }

}
