import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_dam/ServiciosRemotos.dart';
import 'package:proyecto_dam/inicioAdmin.dart';
import 'package:proyecto_dam/inicioSocio.dart';
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
    var rol = await Autenticacion.verificarRol(user);
    if (rol == 'administrador') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (rol == 'socio') {
      Navigator.pushReplacementNamed(context, '/socio');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR")));
    }
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
                SizedBox(height: 15,),
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
                )

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
