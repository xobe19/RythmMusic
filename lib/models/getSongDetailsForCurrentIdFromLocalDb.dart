import 'package:hive/hive.dart';
import 'dart:typed_data';
Future getImage(String songId) async {

var lazyBox2 = await Hive.openLazyBox('imageMain');
return lazyBox2.get(songId);
}
Future getSong(String songId) async {

var lazyBox = await Hive.openLazyBox('songMain');
return  lazyBox.get(songId);
}
Future getTitle(String songId) async {

var lazyBox3 = await Hive.openLazyBox('titleMain');
return  lazyBox3.get(songId);
}


Future getArtist(String songId) async {

var lazyBox5 = await Hive.openLazyBox('artistMain');
return  lazyBox5.get(songId);
}


