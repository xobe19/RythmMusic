import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mainHomeScreen.dart';
import 'phoneSignUpLoading.dart';
import '../models/OtpData.dart';
import 'package:provider/provider.dart';

class PhoneSignUp extends StatefulWidget {
  @override
  _PhoneSignUpState createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends State<PhoneSignUp> {
  String phoneNumber;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              children: [
                Text('Enter Your Phone Number',
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
                      phoneNumber = '+91' + val;
                    }),
                SizedBox(height: 15),
                RaisedButton(
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    Future fut = auth.verifyPhoneNumber(
                        phoneNumber: phoneNumber,
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {
                          await auth.signInWithCredential(credential);
                          Navigator.pushNamedAndRemoveUntil(context,
                              '/homeScreenSongs', ModalRoute.withName('/'));
                        },
                        verificationFailed: (e) async {
                          print(e.code);
                        },
                        codeSent:
                            (String verificationId, int resendToken) async {
                          Navigator.pushNamed(context, '/otpScreen');
                          Stream dat =
                              Provider.of<OtpData>(context, listen: false).data;

                          dat.listen((smsCode) async {
                            print('smsCodeStart');
                            print(smsCode);
                            print('smsCodeEnd');
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: smsCode);
                            await auth.signInWithCredential(credential);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MainHomeScreen();
                            }));
                          });

                          // Sign the user in (or link) with the credential
                        },
                        codeAutoRetrievalTimeout:
                            (String verificationId) async {});
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PhoneLoading(Container(color: Colors.red), fut);
                    }));
                  },
                  color: Color(0xffbb86fc),
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Sign Up',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                )
              ],
            )));
  }
}
