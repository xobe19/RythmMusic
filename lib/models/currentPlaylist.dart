import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:des_plugin/des_plugin.dart';
import '../models/getSongsInPlaylist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doesSongExistinPlaylist.dart';
import 'package:locally/locally.dart';
import '../screens/songScreen.dart';
import '../screens/downloadSongScreen.dart';
const String key = '38346591';

class CurrentPlaylist extends ChangeNotifier {
	var fromDownload;
	var context;
	var locally;
	CurrentPlaylist(BuildContext ctx) {
     this.context = ctx;
  this.locally = Locally(context: context, pageRoute: MaterialPageRoute(builder: (BuildContext context) {
	  if(fromDownload==true) {
		  return DownloadSongScreen(); 
	  }
	  return SongScreen();
  }), appIcon: 'mipmap/ic_launcher', payload: 'test', );
	}
  int downloadLength;
  List snpsht;
  String playlistId;
  var jsonData;
  bool fromPlaylistClick;
  int currentPlaying = 0;
  Duration currentPlayingMaxVal = Duration.zero;
  Duration currentPlayingCurrVal = Duration.zero;
  AudioPlayer currentAudioPlayer;
  var currImage;
  String decrytpedUrl;
  bool isPlaying;
  var isLiked;
  var isVisible;
  var subs1;
  var subs2;
  var checker;
  var subs3;
  Function prevCb;
  Function nextCb;
  Function pauseCb;
  Function playCb;
  Future<bool> init(String pid) async {
    this.currentPlaying = 0;
    this.currentPlayingCurrVal = Duration.zero;
    this.currentPlayingMaxVal = Duration.zero;
    this.fromPlaylistClick = false;
    this.playlistId = pid;
    var tmpString =
        await http.get(Uri.parse(Api.album_details_base_url + this.playlistId));
    var tmpString2 = tmpString.body;
    this.jsonData = json.decode(tmpString2);
    this.currImage = Image.network(this
        .jsonData['songs'][this.currentPlaying]['image']
        .replaceAll('50x50', '500x500'));
    this.decrytpedUrl = await getDecryptedUrl();
    this.isPlaying = false;
    var songId = this.jsonData['songs'][this.currentPlaying]['id'];
    var uid = FirebaseAuth.instance.currentUser.uid;
    this.isLiked = await doesSongExistInPlaylist(uid, songId);
    return true;
  }

  Future<bool> initUser(String pid) async {
    this.currentPlaying = 0;
    this.currentPlayingCurrVal = Duration.zero;
    this.currentPlayingMaxVal = Duration.zero;
    this.fromPlaylistClick = false;
    this.playlistId = pid;
    this.jsonData = await getSongsInPlaylist(this.playlistId);
    this.currImage =
        Image.network(this.jsonData['songs'][this.currentPlaying]['image']);
    this.decrytpedUrl = await getDecryptedUrl();
    this.isPlaying = false;
    var songId = this.jsonData['songs'][this.currentPlaying]['id'];
    var uid = FirebaseAuth.instance.currentUser.uid;
    this.isLiked = await doesSongExistInPlaylist(uid, songId);
    return true;
  }

  Future<String> getDecryptedUrl() async {
    return DesPlugin.decrypt(key,
        this.jsonData['songs'][this.currentPlaying]['encrypted_media_url']);
  }

  Future<String> getDecryptedUrlWithString(String enc) async {
    return DesPlugin.decrypt(key, enc);
  }
}
