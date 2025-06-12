import 'package:flutter/material.dart';


class Historyscreen extends StatelessWidget {
  const Historyscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('History', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        ),


      body: Center(
        child: Container(
          height: 233,
          width: 344,
          color: Colors.black,
        ),
      ),
    );
  }
}