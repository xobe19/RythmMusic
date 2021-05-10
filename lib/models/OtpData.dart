import 'dart:async';
class OtpData {
    Stream data;
    var controller;
    OtpData() {
	   controller = StreamController(); 
	   data = controller.stream;
    }
    setData(String d) {
this.controller.add(d);	    
    }
}
