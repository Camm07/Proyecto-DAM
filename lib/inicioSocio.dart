import 'package:flutter/material.dart';

class Socio extends StatefulWidget {
  const Socio({super.key});

  @override
  State<Socio> createState() => _SocioState();
}

class _SocioState extends State<Socio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOCIO"),
      ),
    );
  }
}
