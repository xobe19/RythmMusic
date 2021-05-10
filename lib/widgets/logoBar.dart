import 'package:flutter/material.dart';

class LogoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            child: Image.asset('images/logo.png'),
          ),
          SizedBox(width: 20),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                      colors: [Colors.pinkAccent, Color(0xffbb86fc)])
                  .createShader(bounds);
            },
            child: Text(
              'Rythm',
              style: TextStyle(
                  color: Colors.white, fontSize: 60, fontFamily: 'Pacifico'),
            ),
          )
        ],
      ),
    );
  }
}
