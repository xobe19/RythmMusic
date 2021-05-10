import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About me:',
              style: TextStyle(
                  color: Color(0xffbb86fc),
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.white),
            Expanded(
                child: Text(
              'This app was developed, designed, and is being maintained by me, Hitesh Lalwani(Github: @xobe19), For any bugs/crashes/feature requests, contact me at my E-mail: lwni@pm.me, hope you like the app!',
              style: TextStyle(color: Colors.white, fontSize: 17.5),
            )),
            SizedBox(height: 20),
            SizedBox(height: 10),
            RaisedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  SystemNavigator.pop();
                },
                color: Color(0xffbb86fc),
                textColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Sign out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))
          ],
        ),
      ),
    );
  }
}
