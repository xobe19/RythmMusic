import 'package:flutter/material.dart';
import '../models/createPlaylist.dart';
import 'mainHomeScreen.dart';

class Cpl extends StatefulWidget {
  @override
  _Cpl createState() => _Cpl();
}

class _Cpl extends State<Cpl> {
  String cpls;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Playlist Name:',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25)),
                SizedBox(height: 10),
                TextField(
                    decoration:
                        InputDecoration(fillColor: Colors.white, filled: true),
                    onChanged: (String val) {
                      cpls = val;
                    }),
                SizedBox(height: 15),
                RaisedButton(
                  onPressed: () async {
                    await createPlaylist(cpls);
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return MainHomeScreen();
                    }));
                  },
                  color: Color(0xffbb86fc),
                  textColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Create Playlist',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                )
              ],
            )));
  }
}
