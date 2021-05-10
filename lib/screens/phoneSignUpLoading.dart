import 'package:flutter/material.dart';
import '../screens/loadingScreen.dart';
import 'errorPage.dart';

class PhoneLoading extends StatelessWidget {
  var ToBeSent;
  var future;
  PhoneLoading(Widget tbs, Future fut) {
    ToBeSent = tbs;
    future = fut;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ErrorPage();
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return this.ToBeSent();
      }
      return LoadingScreen('Verifying Your Phone');
    });
  }
}
