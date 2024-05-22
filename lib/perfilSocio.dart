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
        title: Text('Perfil del Socio'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _cambiarFotoPerfil,
          )
        ],
      ),
      body: socioLocal == null ? CircularProgressIndicator() : ListView(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(socioLocal!.fotoPerfil),
            radius: 60,
          ),
          ListTile(
            title: Text('Nombre: ${socioLocal!.nombre}'),
            subtitle: Text('Apellidos: ${socioLocal!.apellidos}'),
          ),
          ListTile(
            title: Text('Correo: ${socioLocal!.correo}'),
            subtitle: Text('Teléfono: ${socioLocal!.telefono}'),
          ),
          ElevatedButton(
            onPressed: _cambiarFotoPerfil,
            child: Text('Cambiar Foto'),
          )
        ],
      ),
    );
  }
}




