import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/currentPlaylist.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doesSongExistinPlaylist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UserPlaylistScreen extends StatelessWidget {
  String p;
  UserPlaylistScreen(String pp) {
    this.p = pp;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<CurrentPlaylist>(context).initUser(p),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 100),
                  Text('Playlist Empty!',
                      style: TextStyle(fontSize: 30, color: Colors.white))
                ],
              )),
            );
          }
          if (snapshot.hasData) {
            CurrentPlaylist data =
                Provider.of<CurrentPlaylist>(context, listen: false);
            return PlaylistShuffleDl(data: data);
          }
          return Scaffold(
            backgroundColor: Colors.black,
            body:
                Center(child: SpinKitWave(color: Color(0xffbb86fc), size: 50)),
          );
        });
  }
}

class PlaylistShuffleDl extends StatefulWidget {
  const PlaylistShuffleDl({
    Key key,
    @required this.data,
  }) : super(key: key);

  final CurrentPlaylist data;

  @override
  _PlaylistShuffleDlState createState() => _PlaylistShuffleDlState();
}

class _PlaylistShuffleDlState extends State<PlaylistShuffleDl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x101820ff),
        body: Stack(alignment: Alignment.centerRight, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: widget.data.jsonData['image']
                              .replaceAll('150x150', '500x500') ==
                          null
                      ? Container(color: Colors.black)
                      : Image.network(
                          widget.data.jsonData['image']
                              .replaceAll('150x150', '500x500'),
                          fit: BoxFit.cover)),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Image.network(
                        widget.data.jsonData['songs'][index]['image'],
                      ),
                      title: Text(
                          widget.data.jsonData['songs'][index]['song']
                              .replaceAll("&quot;", "\"")
                              .replaceAll("&#039;", "'")
                              .replaceAll("&amp;", "&"),
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                          widget
                              .data.jsonData['songs'][index]['primary_artists']
                              .replaceAll("&quot;", "\"")
                              .replaceAll("&#039;", "'")
                              .replaceAll("&amp;", "&"),
                          style: TextStyle(color: Colors.white)),
                      onTap: () async {
                        widget.data.checker = false;
                        widget.data.fromPlaylistClick = true;
                        widget.data.currentPlaying = index;
                        widget.data.currImage = Image.network(widget
                            .data
                            .jsonData['songs'][widget.data.currentPlaying]
                                ['image']
                            .replaceAll('150x150', '500x500'));
                        print('1');
                        widget.data.decrytpedUrl =
                            await widget.data.getDecryptedUrl();
                        if (widget.data.currentAudioPlayer != null) {
                          await widget.data.currentAudioPlayer.stop();
                          print('1');
                        }
                        print('1');
                        widget.data.currentAudioPlayer = AudioPlayer();
                        print('1');
                        await widget.data.currentAudioPlayer
                            .play(widget.data.decrytpedUrl);
                        widget.data.currentPlayingMaxVal = Duration.zero;

                        widget.data.currentPlayingMaxVal =
                            widget.data.currentAudioPlayer.duration;
                        widget.data.currentPlayingCurrVal = Duration.zero;
                        widget.data.fromDownload = false;
                        print('1');
                        print('yaha');
                        print(widget.data.currentPlayingMaxVal);
                        widget.data.subs2 = widget
                            .data.currentAudioPlayer.onPlayerStateChanged
                            .listen((s) {
                          if (s == AudioPlayerState.PLAYING) {
                            widget.data.checker = true;
                            widget.data.isPlaying = true;
                            (() => widget.data.currentPlayingMaxVal =
                                widget.data.currentAudioPlayer.duration)();
                          }
                          widget.data.subs2.cancel();
                        });

                        var songId = widget.data.jsonData['songs']
                            [widget.data.currentPlaying]['id'];
                        var uid = FirebaseAuth.instance.currentUser.uid;
                        widget.data.isLiked =
                            await doesSongExistInPlaylist(uid, songId);

                        Navigator.pushNamed(context, '/songScreen');
                        widget.data.fromPlaylistClick = false;

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
                      },
                    );
                  },
                  itemCount: widget.data.jsonData['songs'].length,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '   ' +
                        widget.data.jsonData['title']
                            .replaceAll("&quot;", "\"")
                            .replaceAll("&#039;", "'")
                            .replaceAll("&amp;", "&") +
                        '   ',
                    style: TextStyle(
                        backgroundColor: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color(0xffbb86fc)),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  widget.data.jsonData['songs'].shuffle();
                  widget.data.checker = false;
                  widget.data.fromPlaylistClick = true;
                  widget.data.currentPlaying = 0;
                  widget.data.currImage = Image.network(widget.data
                      .jsonData['songs'][widget.data.currentPlaying]['image']
                      .replaceAll('150x150', '500x500'));
                  widget.data.decrytpedUrl =
                      await widget.data.getDecryptedUrl();
                  if (widget.data.currentAudioPlayer != null) {
                    await widget.data.currentAudioPlayer.stop();
                  }
                  widget.data.currentAudioPlayer = AudioPlayer();
                  await widget.data.currentAudioPlayer
                      .play(widget.data.decrytpedUrl);
                  widget.data.currentPlayingMaxVal = Duration.zero;

                  widget.data.currentPlayingMaxVal =
                      widget.data.currentAudioPlayer.duration;
                  widget.data.currentPlayingCurrVal = Duration.zero;
                  print('1');
                  print('yaha');
                  print(widget.data.currentPlayingMaxVal);
                  widget.data.subs2 = widget
                      .data.currentAudioPlayer.onPlayerStateChanged
                      .listen((s) {
                    if (s == AudioPlayerState.PLAYING) {
                      widget.data.checker = true;
                      widget.data.isPlaying = true;
                      (() => widget.data.currentPlayingMaxVal =
                          widget.data.currentAudioPlayer.duration)();
                    }
                    widget.data.subs2.cancel();
                  });

                  var songId = widget.data.jsonData['songs']
                      [widget.data.currentPlaying]['id'];
                  var uid = FirebaseAuth.instance.currentUser.uid;
                  widget.data.isLiked =
                      await doesSongExistInPlaylist(uid, songId);
                  Navigator.pushNamed(context, '/songScreen');

                  widget.data.fromDownload = false;
                  widget.data.fromPlaylistClick = false;
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
                },
                child: Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                        color: Color(0xffbb86fc), shape: BoxShape.circle),
                    child: Center(
                        child: FaIcon(FontAwesomeIcons.random,
                            color: Colors.black, size: 40))),
              )
            ],
          )
        ]));
  }
}
