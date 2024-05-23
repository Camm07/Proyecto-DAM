import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_dam/SocioDB.dart';
import 'package:proyecto_dam/socio.dart';

class LSocios extends StatefulWidget {
  @override
  _LSociosState createState() => _LSociosState();
}

class _LSociosState extends State<LSocios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text("Listado de Socios",style: TextStyle(color: Colors.indigo,fontSize: 30)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SocioDB.obtenerSociosStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Cargando...");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Socio socio = Socio.fromMap(document.data() as Map<String, dynamic>, document.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(socio.fotoPerfil), // Usa la URL de la foto del socio
                  backgroundColor: Colors.transparent,
                ),
                title: Text(socio.nombre + ' ' + socio.apellidos),
                subtitle: Text(socio.correo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarSocio(socio),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: () => _cambiarEstado(socio),
                    ),
                  ],
                ),
                onTap: () => _mostrarDetalleSocio(context, socio),
              );
            }).toList(),
          );

        },
      ),
    );
  }

  void _mostrarDetalleSocio(BuildContext context, Socio socio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Socio'),
          content: SingleChildScrollView(
            child: ListBody(
              children:[
                Text('Nombre: ${socio.nombre} ${socio.apellidos}'),
                Text('Correo: ${socio.correo}'),
                Text('Teléfono: ${socio.telefono}'),
                Text('Estatus: ${socio.status}'),
                Text('ID: ${socio.id}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _editarSocio(Socio socio) {
    final TextEditingController _nombreController = TextEditingController(text: socio.nombre);
    final TextEditingController _apellidosController = TextEditingController(text: socio.apellidos);
    final TextEditingController _correoController = TextEditingController(text: socio.correo);
    final TextEditingController _telefonoController = TextEditingController(text: socio.telefono);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Socio'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _apellidosController,
                  decoration: InputDecoration(labelText: 'Apellidos'),
                ),
                TextField(
                  controller: _correoController,
                  decoration: InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: _telefonoController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                Socio actualizadoSocio = Socio(
                  id: socio.id,
                  nombre: _nombreController.text,
                  apellidos: _apellidosController.text,
                  correo: _correoController.text,
                  telefono: _telefonoController.text,
                  fotoPerfil: socio.fotoPerfil,
                  status: socio.status,
                  uid: socio.uid,
                );
                _actualizarSocio(actualizadoSocio);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _actualizarSocio(Socio socio) {
    SocioDB.actualizarSocio(socio).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Socio actualizado exitosamente'))
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar socio: $error'))
      );
    });
  }



  void _cambiarEstado(Socio socio) {
    String nuevoEstado = socio.status == 'Activo' ? 'Inactivo' : 'Activo';
    SocioDB.cambiarEstadoSocio(socio.id, nuevoEstado).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado cambiado a $nuevoEstado'))
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $error'))
      );
    });
  }

}
