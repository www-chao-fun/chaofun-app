import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:images_picker/images_picker.dart';

class DropWaterPage extends StatefulWidget {
  var arguments;
  DropWaterPage({Key key, this.arguments}) : super(key: key);
  _DropWaterPageState createState() => _DropWaterPageState();
}

class _DropWaterPageState extends State<DropWaterPage> {
  var htmls;
  var pageUrl;
  var videoUrl;
  var counts;
  var totals;
  var percent;
  bool canLoadDown = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  test() async {
    Dio dio = new Dio();
    // Response response = await dio.get('https://v.kuaishouapp.com/s/7QIfhZPS');
    var url =
        'https://video.kuaishou.com/short-video/3xqqqqmhixdaesa?fid=1792445020&cc=share_copylink&followRefer=151&shareMethod=TOKEN&docId=9&kpn=NEBULA&subBiz=BROWSE_SLIDE_PHOTO&photoId=3xqqqqmhixdaesa&shareId=13502090394503&shareToken=X8AFp8OfOMgarsB_A&shareResourceType=PHOTO_OTHER&userId=3xsp2h9mccdnidg&shareType=1&et=1_u%2F2000351990182845361_sl1373bl%24s&shareMode=APP&originShareId=13502090394503&appType=21&shareObjectId=5201657620734641071&shareUrlOpened=0&timestamp=1621217818344&utm_source=app_share&utm_medium=app_share&utm_campaign=app_share&location=app_share';
    Response response = await dio.get(url);
    var document = HtmlParser.parseHTML(response.toString());
    var ele = response.toString();
    // var ele =
    // '''<video crossorigin="anonymous" class="player-video" data-v-1362a4bb></video>''';
    // Clipboard.setData(ClipboardData(text: ele));
    RegExp reg = new RegExp(r'/video/');
    print('html结果');
    print(ele);
    print('ttt123123');
    var a = reg.allMatches(ele);
    print('长度');
    print(a);
    print(a.length);
    print(response);
  }

  void save() async {
    File file = await downloadFile(videoUrl);
    bool res = await ImagesPicker.saveVideoToAlbum(file, albumName: "");

    print(res);
  }

  Future<File> downloadFile(String url) async {
    Dio simple = Dio();
    String savePath = Directory.systemTemp.path + '/' + url.split('/').last;
    var s = await simple.download(url, savePath,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (int count, int total) {
      var realCount = count;
      if (total != null) {
        if (totals == null) {
          setState(() {
            totals = (total / (1024 * 1024)).toStringAsFixed(2);
          });
        }
        setState(() {
          counts = (count / (1024 * 1024)).toStringAsFixed(2);
        });
      }
      print('count $count');
      print('total $total');
    });

    print(savePath);
    File file = new File(savePath);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('我的工具'),
        // ),
        body: Stack(
          children: [
            Container(
              child: ChaoFunWebView(
                url: widget.arguments['url'] != null
                    ? widget.arguments['url']
                    : 'https://v.kuaishouapp.com/s/7QIfhZPS',
                title: '解析视频',
                callBack: (res) async {
                  print('jiexi');
                  print(res.toString());
                  var a = res.split('<video');
                  var b = a[1].split('</video>');
                  var c = b[0];
                  var d = c.split('src="');
                  print('保护video $d');
                  var e;
                  if (widget.arguments['url'].contains('kuaishouapp.com')) {
                    e = d[1].split('" alt')[0];
                  } else if (widget.arguments['url'].contains('douyin.com')) {
                    e = d[1].split('" preload')[0];
                    e = e.toString().replaceAll('playwm', 'play');
                  } else {
                    setState(() {
                      canLoadDown = false;
                    });
                  }

                  if (res.toString().contains('<video')) {
                    print('保护video');
                    print(c);
                    print(d);
                    print(e);
                  }
                  setState(() {
                    videoUrl = e;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              child: Container(
                width: ScreenUtil().setWidth(750),
                alignment: Alignment.center,
                child: MaterialButton(
                  minWidth: ScreenUtil().setWidth(400),
                  color: Colors.blue,
                  onPressed: () {
                    save();
                  },
                  child: (totals != null) && (totals == counts)
                      ? Text(
                          '下载完成',
                          style: TextStyle(color: Colors.white),
                        )
                      : Text(
                          '下载视频 ' +
                              (totals != null
                                  ? ('(' +
                                      counts.toString() +
                                      ' / ' +
                                      totals.toString() +
                                      ')')
                                  : ''),
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
