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
import '../models/getSongDetailsForCurrentIdFromLocalDb.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DownloadSongScreen extends StatefulWidget {
  @override
  var data = null;
  _DownloadSongScreenState createState() => _DownloadSongScreenState();
}

class _DownloadSongScreenState extends State<DownloadSongScreen> {
  bool fromFwdButton = false;

  void samp() async {
    if (widget.data.currentPlaying + 1 < widget.data.snpsht.length) {
      widget.data.currentPlaying++;

      var imgData =
          await getImage(widget.data.snpsht[widget.data.currentPlaying]);
      widget.data.currImage = Image.memory(imgData);
      if (widget.data.currentAudioPlayer != null) {
        await widget.data.currentAudioPlayer.stop();
      }
      widget.data.currentAudioPlayer = AudioPlayer();

      final file =
          new File('${(await getTemporaryDirectory()).path}/music.mp3');
      Uint8List songDataTemp =
          await getSong(widget.data.snpsht[widget.data.currentPlaying]);
      await file.writeAsBytes(songDataTemp, mode: FileMode.write);
      await widget.data.currentAudioPlayer.play(file.path, isLocal: true);

      widget.data.currentPlayingMaxVal =
          widget.data.currentAudioPlayer.duration;
      widget.data.currentPlayingCurrVal = Duration.zero;

      // widget.data =
      //     Provider.of<CurrentPlaylist>(context, listen: false);
      widget.data.locally.cancelAll().then((_) async {
        widget.data.locally.show(
            title: 'Currenty Playing ' +
                await getTitle(widget.data.snpsht[widget.data.currentPlaying]),
            message: 'Tap to return to app',
            importance: Importance.low,
            priority: Priority.min,
            color: Color(0xffbb86fc));
      });
      setState(() {});
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

    var title = 'Downloads';
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
              FutureBuilder(
                future:
                    getTitle(widget.data.snpsht[widget.data.currentPlaying]),
                builder: (context, snapshot3) {
                  if (snapshot3.hasData) {
                    return Text(
                        snapshot3.data
                            .replaceAll("&quot;", "\"")
                            .replaceAll("&#039;", "'")
                            .replaceAll("&amp;", "&"),
                        style: TextStyle(color: Colors.white, fontSize: 30));
                  }
                  return Text('');
                },
              ),
              FutureBuilder(
                future:
                    getArtist(widget.data.snpsht[widget.data.currentPlaying]),
                builder: (context, snapshot5) {
                  if (snapshot5.hasData) {
                    return Text(
                        snapshot5.data
                            .replaceAll("&quot;", "\"")
                            .replaceAll("&#039;", "'")
                            .replaceAll("&amp;", "&"),
                        style:
                            TextStyle(color: Color(0xffbb86fc), fontSize: 20));
                  }
                  return Text('');
                },
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

                        var imgData = await getImage(
                            widget.data.snpsht[widget.data.currentPlaying]);
                        widget.data.currImage = Image.memory(imgData);

                        await widget.data.currentAudioPlayer.stop();
                        widget.data.currentAudioPlayer = AudioPlayer();

                        final file = new File(
                            '${(await getTemporaryDirectory()).path}/music.mp3');
                        Uint8List songDataTemp = await getSong(
                            widget.data.snpsht[widget.data.currentPlaying]);
                        await file.writeAsBytes(songDataTemp,
                            mode: FileMode.write);
                        await widget.data.currentAudioPlayer
                            .play(file.path, isLocal: true);

                        widget.data.currentPlayingMaxVal =
                            widget.data.currentAudioPlayer.duration;

                        widget.data.currentPlayingCurrVal = Duration.zero;

                        fromFwdButton = false;
                        setState(() {});
                        widget.data.locally.cancelAll().then((_) async {
                          widget.data.locally.show(
                              title: 'Currenty Playing ' +
                                  await getTitle(widget
                                      .data.snpsht[widget.data.currentPlaying]),
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
                          widget.data.snpsht.length) {
                        widget.data.currentPlaying++;

                        var imgData = await getImage(
                            widget.data.snpsht[widget.data.currentPlaying]);
                        widget.data.currImage = Image.memory(imgData);

                        await widget.data.currentAudioPlayer.stop();
                        widget.data.currentAudioPlayer = AudioPlayer();

                        final file = new File(
                            '${(await getTemporaryDirectory()).path}/music.mp3');
                        Uint8List songDataTemp = await getSong(
                            widget.data.snpsht[widget.data.currentPlaying]);
                        await file.writeAsBytes(songDataTemp,
                            mode: FileMode.write);
                        await widget.data.currentAudioPlayer
                            .play(file.path, isLocal: true);
                        widget.data.currentPlayingMaxVal =
                            await widget.data.currentAudioPlayer.getDuration();
                        widget.data.currentPlayingCurrVal = Duration.zero;
                        fromFwdButton = false;
                        setState(() {});
                        widget.data.locally.cancelAll().then((_) async {
                          widget.data.locally.show(
                              title: 'Currenty Playing ' +
                                  await getTitle(widget
                                      .data.snpsht[widget.data.currentPlaying]),
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
            ]),
          ),
        ));
  }
}
