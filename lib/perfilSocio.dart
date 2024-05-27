import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_dam/socio.dart';
import 'package:proyecto_dam/SocioDB.dart';
import 'package:proyecto_dam/ServicioStorage.dart';

class PerfilSocio extends StatefulWidget {
  final Socio? socio;

  PerfilSocio({Key? key, this.socio}) : super(key: key);

  @override
  _PerfilSocioState createState() => _PerfilSocioState();
}

class _PerfilSocioState extends State<PerfilSocio> {
  final ImagePicker _picker = ImagePicker();
  Socio? socioLocal;

  @override
  void initState() {
    super.initState();
    // Asegurarte de que tienes un socio cuando inicia el widget
    socioLocal = widget.socio;
    if (socioLocal == null) {
      cargarDatosSocio();
    }
  }

  Future<void> cargarDatosSocio() async {
    socioLocal = await SocioDB.obtenerSocioActual();
    setState(() {});
  }

  Future<void> _cambiarFotoPerfil() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && socioLocal != null) {
      String? url = await ServicioStorage().subirImagen(image.path, socioLocal!.uid);
      if (url != null) {
        setState(() {
          socioLocal!.fotoPerfil = url;
        });
        await SocioDB.actualizarSocio(socioLocal!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Perfil',style: TextStyle(color: Colors.indigo,fontSize: 30),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit,color: Colors.indigo,),
            onPressed: _cambiarFotoPerfil,
          )
        ],
      ),
      body: socioLocal == null ? CircularProgressIndicator() : Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(socioLocal!.fotoPerfil),
              radius: 65,
            ),
            SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Nombre: ${socioLocal!.nombre}',style: TextStyle(fontSize: 18),),
          ),
            SizedBox(height: 10,),
           Padding(
             padding: const EdgeInsets.all(10),
             child: Text('Apellidos: ${socioLocal!.apellidos}',style: TextStyle(fontSize: 18)),
           ),
            SizedBox(height: 10,),
           Padding(
             padding: const EdgeInsets.all(10),
             child: Text('Correo: ${socioLocal!.correo}',style: TextStyle(fontSize: 18)),
           ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Teléfono: ${socioLocal!.telefono}',style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _cambiarFotoPerfil,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cambiar Foto',style: TextStyle(fontSize: 18),),
                  SizedBox(width: 30,),
                  Icon(Icons.photo_camera)
                ],
              ),
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
    );
  }
}




