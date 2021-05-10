import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(child: Image.asset('images/404.png', fit: BoxFit.cover)),
                    flex: 1,
                  ),
                  Expanded(
                      child: Center(
                        child: Text(
                    'Ow, Snap! Something went wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
		      fontWeight: FontWeight.bold
                    ),
                  ),
                      ))
                ],
              )),
        ));
  }
}
