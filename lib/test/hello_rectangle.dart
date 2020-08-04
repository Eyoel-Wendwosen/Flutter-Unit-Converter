import 'package:flutter/material.dart';

class HelloRectangel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.greenAccent,
        height: 400.0,
        width: 300.0,
        child: Center(
          child: Text(
            "Hell0",
            style: TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }
}
