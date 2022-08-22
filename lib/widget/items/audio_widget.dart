import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/widget/common/customNavgator.dart';
import 'package:flutter_chaofan/widget/im/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://www.baidu.com';

class AudioWidget extends StatefulWidget {
  var item;
  AudioWidget({Key key, this.item}) : super(key: key);

  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> with TickerProviderStateMixin {
  var item;
  var urlvali;
  Duration duration = new Duration();
  var init = false;

  AudioPlayer player = AudioPlayer();
  var playing = false;

  @override
  void initState() {
    super.initState();
    getDuration();

  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<void> getDuration() async {
    if (init == false) {
      try {
        var tmpDuration = await player.setAudioSource(AudioSource.uri(Uri.parse('https://i.chao-fan.com/' + widget.item['audio'])));
            if (tmpDuration != null) {
          setState(() {
            duration = tmpDuration;
          });
        }
        init = true;
      } catch (e) {

      }
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    var leftSoundNames = [
      'assets/images/chat/sound_left_0.webp',
      'assets/images/chat/sound_left_1.webp',
      'assets/images/chat/sound_left_2.webp',
      'assets/images/chat/sound_left_3.webp',
    ];
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    Widget body = new Container(
      width: ScreenUtil().setWidth(380),
      padding: EdgeInsets.only(right: 10.0),
      child: new FlatButton(
        padding: EdgeInsets.only(left: 18.0, right: 4.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Text('');
                } else if (playing != true) {
                  return Text('');
                } else if (processingState != ProcessingState.completed) {
                  return Text('播放中...');
                } else {
                  player.stop();
                  return Text('');
                }
              }
            ),
            new Text(twoDigits((duration.inSeconds / 60).toInt()) + ':' + twoDigits((duration.inSeconds % 60).toInt()) , textAlign: TextAlign.start, maxLines: 1),
            new Space(width: 10.0 / 2),
            new Image.asset(
                leftSoundNames[3],
                height: 20.0,
                color: Theme.of(context).textTheme.titleLarge.color,
                fit: BoxFit.cover),
            new Space(width: 10.0)
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onPressed: () async {
          if (!player.playing) {
            player.setAudioSource(AudioSource.uri(Uri.parse('https://i.chao-fan.com/' + widget.item['audio'])));
            player.play();
          } else {
            player.stop();
          }
        },
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(children: [body]),
    );
    // item = widget.item;
    // return Container();
  }

  playNew() async {
    player.play();
  }


}
