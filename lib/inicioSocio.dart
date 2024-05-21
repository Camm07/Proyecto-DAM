import 'package:flutter/material.dart';
import 'package:proyecto_dam/main.dart';

class Socio extends StatefulWidget {
  const Socio({super.key});

  @override
  State<Socio> createState() => _SocioState();
}

class _SocioState extends State<Socio> {
  int _indice=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOCIO"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
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
                    CircleAvatar(
                      child: Text("ITT",style: TextStyle(color: Colors.black),),radius: 30,backgroundColor: Colors.orangeAccent,),
                      Text("Tecnológico de Tepic",),
                      Text("(C) Derechos reservados",),
                  ],
                ),
              decoration: BoxDecoration(
                color: Color(0xFFFFC107).withOpacity(0.6)
              ),
            ),
            SizedBox(height: 30,),
            itemDrawer(1,Icons.home,"Inicio",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(2,Icons.person,"Perfil",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(3,Icons.email,"Solicitud",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(4,Icons.calendar_month,"Reservacion",Colors.orangeAccent),
            SizedBox(height: 20,),
            itemDrawer(5,Icons.output,"Cerrar Sesion",Colors.orangeAccent),
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
      case 5: return Cerrar();
      default:
        return Inicio();
    }
  }

  itemDrawer(int indice, IconData icono, String etiqueta, Color color) {
    return ListTile(
      onTap: (){
        setState(() {
          _indice = indice;
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [
          Expanded(child: Icon(icono, color: color,),),
          Expanded(child: Text(etiqueta,style: TextStyle(fontSize: 20),),flex: 2,)
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

  Widget Cerrar() {
    return AlertDialog(
      title: Text("Cerrar Sesion"),
      content: Text("¿Estas Seguro de quere Cerrar Sesion?",
        style: TextStyle(
            fontSize: 20,
            color: Colors.black
        ),),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>MyApp()),
              );
            },
            child: Text("SI")
        ),
        SizedBox(width: 20,),
        TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>Socio()),
              );
            },
            child: Text("NO")
        )
      ],
    );
  }





}
