import 'package:flutter/material.dart';
import 'package:rythm_app/screens/mainHomeScreen.dart';
import '../auth/emailAuth.dart';
import 'loadingScreen.dart';
import 'errorPage.dart';

class EmailSignUpInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xff18191a), body: FieldStful());
  }
}

class FieldStful extends StatefulWidget {
  @override
  _FieldStfulState createState() => _FieldStfulState();
}

class _FieldStfulState extends State<FieldStful> {
  String email;
  String pass;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Email',
                style: TextStyle(
                    color: Color(0xffbb86fc),
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (String em) {
                email = em;
              },
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Password',
                style: TextStyle(
                    color: Color(0xffbb86fc),
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (String pa) {
                pass = pa;
              },
            ),
            SizedBox(height: 20),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FutureBuilder(
                        future: EmailAuthenticator().signUp(email, pass),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return ErrorPage();
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            EmailAuthenticator().getUser((user) async {
                              if (!user.emailVerified) {
                                await user.sendEmailVerification();
                              }
                            });

                            return MainHomeScreen();
                          }
                          return LoadingScreen('Creating Your Account');
                        });
                  }));
                },
                color: Color(0xffbb86fc),
                textColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Sign Up',
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
