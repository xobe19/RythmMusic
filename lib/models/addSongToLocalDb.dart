import 'package:hive/hive.dart';
import 'dart:typed_data';
Future<bool> addSongToLocalDb(String songId, Uint8List songData, Uint8List imageData, String songName, String artistName) async {
var lazyBox = await Hive.openLazyBox('songMain');
await lazyBox.put(songId, songData);
var lazyBox2 = await Hive.openLazyBox('imageMain');
await lazyBox2.put(songId, imageData);
var lazyBox3 = await Hive.openLazyBox('titleMain');
await lazyBox3.put(songId, songName); 
var lazyBox4 = await Hive.openLazyBox('main');
List songIdList = await lazyBox4.get('ids');
var lazyBox5 = await Hive.openLazyBox('artistMain');
await lazyBox5.put(songId, artistName);
if(songIdList == null) {
await	lazyBox4.put('ids', [songId]);
}
else {
if(	songIdList.indexOf(songId) == -1) {
    
   	songIdList.add(songId);
}

	await lazyBox4.put('ids', songIdList);
}
return true;


}

