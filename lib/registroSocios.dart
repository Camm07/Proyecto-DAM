import 'package:flutter/material.dart';
import 'package:proyecto_dam/SocioDB.dart';
import 'package:proyecto_dam/socio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RSocios extends StatefulWidget {
  @override
  _RSociosState createState() => _RSociosState();
}

class _RSociosState extends State<RSocios> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Socio",style: TextStyle(color: Colors.indigo,fontSize: 30),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre',
                  suffixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: _apellidosController,
              decoration: InputDecoration(labelText: 'Apellidos',
                  suffixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo',
                  suffixIcon: Icon(Icons.mail)),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono',
                  suffixIcon: Icon(Icons.call)),
            ),
            TextField(
              controller: _curpController,
              decoration: InputDecoration(labelText: 'CURP',
                  suffixIcon: Icon(Icons.dashboard)),
            ),
            TextField(
              controller: _contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña',
                  suffixIcon: Icon(Icons.password)),
              obscureText: true,
            ),
            SizedBox(height: 35),
            ElevatedButton(
              onPressed: _registrarSocio,
              child: Text('Registrar Socio'),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarSocio() async {
    final String nombre = _nombreController.text;
    final String apellidos = _apellidosController.text;
    final String correo = _correoController.text;
    final String telefono = _telefonoController.text;
    final String curp = _curpController.text;
    final String contrasena = _contrasenaController.text;

    try {
      // Crear usuario en FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Crear socio en Firestore
      Socio nuevoSocio = Socio(
        nombre: nombre,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        fotoPerfil: "https://firebasestorage.googleapis.com/v0/b/proyecto-club-c2df1.appspot.com/o/socio.png?alt=media&token=b766c205-80ec-45c6-bc3b-d6aadbcbb010",
        status: "Activo",
        uid: userCredential.user!.uid,
      );

      await SocioDB.agregarSocio(nuevoSocio);

      // Limpiar campos
      _nombreController.clear();
      _apellidosController.clear();
      _correoController.clear();
      _telefonoController.clear();
      _curpController.clear();
      _contrasenaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Socio registrado exitosamente'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar socio: ${e.toString()}'))
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _curpController.dispose();
    super.dispose();
  }
}
