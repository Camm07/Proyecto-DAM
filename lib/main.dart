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
    return Scaffold(
      appBar: AppBar(
        title: Text("Autenticar"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "Correo:"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: password,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: "Contraseña:",
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: handleLogin,
                child: Text("AUTENTICAR"),
              ),
              // Agrega botones o funcionalidades adicionales según sea necesario
            ],
          ),
        ),
      ),
    );
  }
}
