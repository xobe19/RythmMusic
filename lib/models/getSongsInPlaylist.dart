import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String,dynamic>> getSongsInPlaylist(String pid) async {
	FirebaseFirestore firstore = FirebaseFirestore.instance;
	CollectionReference ref1 = firstore.collection('playlists');
	Map<String, dynamic> finalData = Map<String, dynamic>();
	QuerySnapshot qs = await ref1.where('playlistString', isEqualTo: pid).get();
        QuerySnapshot qs2 = await qs.docs[0].reference.collection('songs').get();
	finalData['image'] = qs.docs[0].get('image');
        finalData['title'] = qs.docs[0].get('title');
finalData['songs'] = [];
for(int i = 0; i < qs2.docs.length; i++) {

  finalData['songs'].add(qs2.docs[i].get('songData')); 
}
	return finalData;
}
