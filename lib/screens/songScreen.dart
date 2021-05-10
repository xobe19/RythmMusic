import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/currentPlaylist.dart';
import 'package:provider/provider.dart';
import 'package:audioplayer/audioplayer.dart';
import '../models/deleteSong.dart';
import '../models/addSongToPlaylist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doesSongExistinPlaylist.dart';
import '../api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/addSongToLocalDb.dart';
import 'dart:typed_data';
import 'package:locally/locally.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SongScreen extends StatefulWidget {
  @override
  var data = null;
  _SongScreenState createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  bool fromFwdButton = false;
  Future<bool> checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      var result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }

    return false;
  }

  void samp() async {
    if (widget.data.currentPlaying + 1 < widget.data.jsonData['songs'].length) {
      widget.data.currentPlaying++;
      widget.data.currImage = Image.network(widget
          .data.jsonData['songs'][widget.data.currentPlaying]['image']
          .replaceAll('150x150', '500x500'));
      widget.data.decrytpedUrl = await widget.data.getDecryptedUrl();
      await widget.data.currentAudioPlayer.stop();

      widget.data.currentAudioPlayer = AudioPlayer();
      await widget.data.currentAudioPlayer.play(widget.data.decrytpedUrl);
      widget.data.currentPlayingMaxVal = Duration.zero;

      widget.data.currentPlayingMaxVal =
          widget.data.currentAudioPlayer.duration;
      widget.data.currentPlayingCurrVal = Duration.zero;

      // widget.data =
      //     Provider.of<CurrentPlaylist>(context, listen: false);
      var songId =
          widget.data.jsonData['songs'][widget.data.currentPlaying]['id'];
      var uid = FirebaseAuth.instance.currentUser.uid;
      widget.data.isLiked = await doesSongExistInPlaylist(uid, songId);
      setState(() {});

      widget.data.locally.cancelAll().then((_) {
        widget.data.locally.show(
            title: 'Currenty Playing ' +
                widget.data.jsonData['songs'][widget.data.currentPlaying]
                    ['song'],
            message: 'Tap to return to app',
            importance: Importance.low,
            priority: Priority.min,
            color: Color(0xffbb86fc));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      widget.data = Provider.of<CurrentPlaylist>(context, listen: false);
    }

    widget.data.subs1 = widget.data.currentAudioPlayer.onAudioPositionChanged
        .listen((Duration p) {
      widget.data.currentPlayingCurrVal = p;
      setState(() {});
      widget.data.subs1.cancel();
    });
    widget.data.subs2 =
        widget.data.currentAudioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        widget.data.checker = true;
        widget.data.isPlaying = true;
        setState(() => widget.data.currentPlayingMaxVal =
            widget.data.currentAudioPlayer.duration);
      }

      if (s == AudioPlayerState.STOPPED &&
          widget.data.checker &&
          !fromFwdButton &&
          !widget.data.fromPlaylistClick) {
        print('this was called!');
        widget.data.checker = false;
        samp();
        print('i hope this was too!');
      }
      widget.data.subs2.cancel();
      setState(() {});
    });

    var title = widget.data.jsonData['title']
        .replaceAll("&quot;", "\"")
        .replaceAll("&#039;", "'")
        .replaceAll("&amp;", "&");

    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Playing From: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: title,
                          style: TextStyle(color: Color(0xffbb86fc)))
                    ],
                  ),
                ),
              ),
              Expanded(child: widget.data.currImage),
              Text(
                widget
                    .data.jsonData['songs'][widget.data.currentPlaying]['song']
                    .replaceAll("&quot;", "\"")
                    .replaceAll("&#039;", "'")
                    .replaceAll("&amp;", "&"),
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              Text(
                widget
                    .data
                    .jsonData['songs'][widget.data.currentPlaying]
                        ['primary_artists']
                    .replaceAll("&quot;", "\"")
                    .replaceAll("&#039;", "'")
                    .replaceAll("&amp;", "&"),
                style: TextStyle(color: Color(0xffbb86fc), fontSize: 20),
              ),
              Slider(
                  value: widget.data.currentPlayingCurrVal.inSeconds.toDouble(),
                  onChanged: (double val) {
                    widget.data.currentAudioPlayer.seek(val);

                    setState(() {});
                  },
                  min: 0,
//TODO: lyrics modal bottom sheet
                  max: widget.data.currentPlayingMaxVal.inSeconds.toDouble(),
                  activeColor: Color(0xffbb86fc),
                  inactiveColor: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.data.currentPlayingCurrVal.inMinutes.toString() +
                        ':' +
                        (widget.data.currentPlayingCurrVal.inSeconds % 60)
                            .toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    child: FaIcon(FontAwesomeIcons.stepBackward,
                        color: Colors.white),
                    onTap: () async {
                      if (widget.data.currentPlaying - 1 >= 0) {
                        fromFwdButton = true;
                        widget.data.currentPlaying--;
                        widget.data.currImage = Image.network(widget
                            .data
                            .jsonData['songs'][widget.data.currentPlaying]
                                ['image']
                            .replaceAll('150x150', '500x500'));
                        widget.data.decrytpedUrl =
                            await widget.data.getDecryptedUrl();
                        await widget.data.currentAudioPlayer.stop();
                        widget.data.currentAudioPlayer = AudioPlayer();
                        await widget.data.currentAudioPlayer
                            .play(widget.data.decrytpedUrl);

                        widget.data.currentPlayingMaxVal = Duration.zero;

                        widget.data.currentPlayingMaxVal =
                            widget.data.currentAudioPlayer.duration;
                        print('maxval');
                        print(widget.data.currentPlayingMaxVal);
                        print('mend');
                        widget.data.currentPlayingCurrVal = Duration.zero;
                        var songId = widget.data.jsonData['songs']
                            [widget.data.currentPlaying]['id'];
                        var uid = FirebaseAuth.instance.currentUser.uid;
                        widget.data.isLiked =
                            await doesSongExistInPlaylist(uid, songId);

                        fromFwdButton = false;
                        setState(() {});
                        widget.data.locally.cancelAll().then((_) {
                          widget.data.locally.show(
                              title: 'Currenty Playing ' +
                                  widget.data.jsonData['songs']
                                      [widget.data.currentPlaying]['song'],
                              message: 'Tap to return to app',
                              importance: Importance.low,
                              priority: Priority.min,
                              color: Color(0xffbb86fc));
                        });
                      }
                    },
                  ),
                  GestureDetector(
                      child: widget.data.isPlaying
                          ? FaIcon(FontAwesomeIcons.solidPauseCircle,
                              size: 60, color: Color(0xffbb86fc))
                          : FaIcon(
                              FontAwesomeIcons.solidPlayCircle,
                              color: Color(0xffbb86fc),
                              size: 60,
                            ),
                      onTap: () async {
                        if (widget.data.isPlaying) {
                          widget.data.isPlaying = false;
                          await widget.data.currentAudioPlayer.pause();
                          setState(() {});
                        } else {
                          widget.data.isPlaying = true;
                          widget.data.currentAudioPlayer.play('nonsense');
                          setState(() {});
                        }
                      }),
                  GestureDetector(
                    child: FaIcon(FontAwesomeIcons.stepForward,
                        color: Colors.white),
                    onTap: () async {
                      fromFwdButton = true;
                      if (widget.data.currentPlaying + 1 <
                          widget.data.jsonData['songs'].length) {
                        widget.data.currentPlaying++;
                        widget.data.currImage = Image.network(widget
                            .data
                            .jsonData['songs'][widget.data.currentPlaying]
                                ['image']
                            .replaceAll('150x150', '500x500'));
                        widget.data.decrytpedUrl =
                            await widget.data.getDecryptedUrl();
                        await widget.data.currentAudioPlayer.stop();

                        widget.data.currentAudioPlayer = AudioPlayer();
                        await widget.data.currentAudioPlayer
                            .play(widget.data.decrytpedUrl);
                        widget.data.currentPlayingMaxVal = Duration.zero;

                        widget.data.currentPlayingMaxVal =
                            widget.data.currentAudioPlayer.duration;
                        widget.data.currentPlayingCurrVal = Duration.zero;

                        var songId = widget.data.jsonData['songs']
                            [widget.data.currentPlaying]['id'];
                        var uid = FirebaseAuth.instance.currentUser.uid;
                        widget.data.isLiked =
                            await doesSongExistInPlaylist(uid, songId);

                        // widget.data =
                        //     Provider.of<CurrentPlaylist>(context, listen: false);
                        fromFwdButton = false;
                        setState(() {});

                        widget.data.locally.cancelAll().then((_) {
                          widget.data.locally.show(
                              title: 'Currenty Playing ' +
                                  widget.data.jsonData['songs']
                                      [widget.data.currentPlaying]['song'],
                              message: 'Tap to return to app',
                              importance: Importance.low,
                              priority: Priority.min,
                              color: Color(0xffbb86fc));
                        });
                      }
                    },
                  ),
                  Text(
                    widget.data.currentPlayingMaxVal.inMinutes.toString() +
                        ':' +
                        (widget.data.currentPlayingMaxVal.inSeconds % 60)
                            .toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Icon(Icons.playlist_add, color: Colors.white),
                    onTap: () {
                      Navigator.pushNamed(context, '/addToPlaylistScreen');
                    },
                  ),
                  GestureDetector(
                      child: widget.data.isLiked
                          ? FaIcon(FontAwesomeIcons.solidHeart,
                              color: Color(0xffbb86fc))
                          : FaIcon(FontAwesomeIcons.heart, color: Colors.white),
                      onTap: () async {
                        if (widget.data.isLiked) {
                          await deleteSong(
                              FirebaseAuth.instance.currentUser.uid,
                              widget.data.jsonData['songs']
                                  [widget.data.currentPlaying]['id']);
                          widget.data.isLiked = false;
                          setState(() {});
                        } else {
                          await addSongToPlaylist(
                              FirebaseAuth.instance.currentUser.uid,
                              widget.data.jsonData['songs']
                                  [widget.data.currentPlaying]);
                          widget.data.isLiked = true;
                          setState(() {});
                        }
                      }),
                  GestureDetector(
                    child: ImageIcon(
                      AssetImage('images/lyrics.png'),
                      color: Color(0xffbb86fc),
                    ),
                    onTap: () async {
                      var lyrics = Api.lyrics_base_url +
                          widget.data.jsonData['songs']
                              [widget.data.currentPlaying]['id'];
                      var lyricsJson = await http.get(Uri.parse(lyrics));
                      var lyricsObject = await json.decode(lyricsJson.body);
                      String lyricsFinalString = lyricsObject['lyrics'] != null
                          ? lyricsObject['lyrics']
                          : 'Lyrics Not Available for this song!';
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              color: Colors.black,
                              padding: EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                  child: Column(
                                children: [
                                  Text(
                                    'Lyrics:',
                                    style: TextStyle(
                                        color: Color(0xffbb86fc), fontSize: 30),
                                  ),
                                  Text(
                                    lyricsFinalString
                                        .replaceAll('<br>', '\n')
                                        .replaceAll("&quot;", "\"")
                                        .replaceAll("&#039;", "'")
                                        .replaceAll("&amp;", "&"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ],
                              )),
                            );
                          });
                    },
                  ),
                  GestureDetector(
                    child:
                        FaIcon(FontAwesomeIcons.download, color: Colors.white),
                    onTap: () async {
                      var snackBar2 = SnackBar(
                          content: Text(
                            'Downloading...',
                            style: TextStyle(color: Color(0xffbb86fc)),
                          ),
                          backgroundColor: Colors.black);

                      print('step 1 dl');
                      ScaffoldMessenger.of(context).showSnackBar(snackBar2);

                      print('step 1 dl');
                      Uint8List tmp1 =
                          (await http.get(Uri.parse(widget.data.decrytpedUrl)))
                              .bodyBytes;

                      print('step 1 dl');
                      Uint8List tmp2 = (await http.get(Uri.parse(widget
                              .data
                              .jsonData['songs'][widget.data.currentPlaying]
                                  ['image']
                              .replaceAll('150x150', '500x500'))))
                          .bodyBytes;

                      print('step 1 dl');
                      String tmp3 = widget.data.jsonData['songs']
                          [widget.data.currentPlaying]['song'];

                      print('step 1 dl');
                      String tmp4 = widget.data.jsonData['songs']
                          [widget.data.currentPlaying]['primary_artists'];

                      print('step 1 dl');

                      await addSongToLocalDb(
                          widget.data.jsonData['songs']
                              [widget.data.currentPlaying]['id'],
                          tmp1,
                          tmp2,
                          tmp3,
                          tmp4);

                      print('step 1 dl');
                      var snackBar = SnackBar(
                          content: Text(
                            'Downloaded!, You Can Download Songs Multiple Times.',
                            style: TextStyle(color: Color(0xffbb86fc)),
                          ),
                          backgroundColor: Colors.black);

                      if (await checkPermission()) {
                        var localPath =
                            '/storage/emulated/0' + '/' + 'RythmDownloads';
                        var savedDir = Directory(localPath);
                        bool hasExisted = await savedDir.exists();
                        if (!hasExisted) {
                          savedDir.create();
                        }
                        File tmpFile = File(localPath + '/' + tmp3 + '.mp3');
                        await tmpFile.writeAsBytes(tmp1, mode: FileMode.write);
                      }
                      print('step 1 dl');
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  )
                ],
              )
            ]),
          ),
        ));
  }
}
