import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/OtpData.dart';

class Otp extends StatefulWidget {
  @override
  _Otp createState() => _Otp();
}

class _Otp extends State<Otp> {
  String otp;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              children: [
                Text('Enter Your OTP',
                    style: TextStyle(
                        color: Color(0xffbb86fc),
                        fontWeight: FontWeight.bold,
                        fontSize: 25)),
                SizedBox(height: 10),
                TextField(
                    decoration:
                        InputDecoration(fillColor: Colors.white, filled: true),
                    keyboardType: TextInputType.phone,
                    onChanged: (String val) {
                      otp = val;
                    }),
                SizedBox(height: 15),
                RaisedButton(
                  onPressed: () {
                    var data = Provider.of<OtpData>(context, listen: false);
                    data.setData(otp);
                    Navigator.pop(context);
                  },
                  color: Color(0xffbb86fc),
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Verify OTP',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                )
              ],
            )));
  }
}
