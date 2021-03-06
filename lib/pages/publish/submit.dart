import 'dart:async';
import 'dart:convert' hide Codec;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/font.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/collect/collect_add_page.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/pages/post_detail/webview_flutter.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/im/ui.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'package:flutter_chaofan/database/userhelper.dart';
import 'package:flutter_chaofan/database/model/userDB.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../delta_to_html/delta_markdown.dart';
import '../delta_to_html/html_renderer.dart';

class SubmitPage extends StatefulWidget {
  var arguments;
  SubmitPage({Key key, this.arguments}) : super(key: key);
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  Widget forumNameWidget;
  TextEditingController _inputController = TextEditingController();
  TextEditingController _linkurlController = TextEditingController();


  QuillController _controller = QuillController.basic();
  ScrollController _scrollController = ScrollController();


  final FocusNode _focusNode = FocusNode();


  var tagList = [];
  var typesList = [
    {
      'type': 'article',
      'label': '??????',
      'icon': 'assets/images/_icon/t1.png',
      'actIcon': 'assets/images/_icon/s1.png',
    },
    {
      'type': 'image',
      'label': '??????',
      'icon': 'assets/images/_icon/t2.png',
      'actIcon': 'assets/images/_icon/s2.png',
    },
    {
      'type': 'inner_video',
      'label': '??????',
      'icon': 'assets/images/_icon/t3.png',
      'actIcon': 'assets/images/_icon/s3.png',
    },
    {
      'type': 'audio',
      'label': '??????',
      'icon': 'assets/images/_icon/t7.png',
      'actIcon': 'assets/images/_icon/s7.png',
    },
    {
      'type': 'link',
      'label': '??????',
      'icon': 'assets/images/_icon/t4.png',
      'actIcon': 'assets/images/_icon/s4.png',
    },
    {
      'type': 'vote',
      'label': '??????',
      'icon': 'assets/images/_icon/t5.png',
      'actIcon': 'assets/images/_icon/s5.png',
    },
  ];
  List<Map> picks = [
    {
      'title': '????????????',
      'icon': Icon(
        Icons.camera_alt,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(60),
      ),
      'value': 1
    },
    {
      'title': '???????????????',
      'icon': Icon(
        Icons.photo_library,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(56),
      ),
      'value': 3
    },
  ];
  List<Map> picksVideo = [
    {
      'title': '?????????',
      'icon': Icon(
        Icons.camera_alt,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(60),
      ),
      'value': 1
    },
    {
      'title': '????????????',
      'icon': Icon(
        Icons.photo_library,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(56),
      ),
      'value': 3
    },
  ];
  String forumId;
  String forumName;
  String forumImageName;
  Widget forumRow;
  var postType = 'image';
  var tagId = '';

  var isLoading = false;
  List imageList = [];
  List imagesUrl = [];
  var chooseType;
  var videoUrl;
  var audioUrl;
  bool canSub = true;
  final _picker = ImagePicker();
  var counts;
  var totals;
  var percent = 0.0;
  bool isRecording = false;
  Duration duration = new Duration();
  var assetsVideo;
  var assetsAudio;
  var clipboardDatas;
  var collectionId = '';
  var collectName;
  var fromDraft = false;
  List<Map> voteList = [
    {'optionName': ''},
    {'optionName': ''},
  ];
  collectionlist(types) async {
    var res = await HttpUtil().get(Api.collectionlist, parameters: {});
    if (res['success'] && res['data'] != null) {
      var data = res['data'];
      var a = [];
      a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      if (collectionId != '') {
        a.forEach((its) {
          if (its['id'].toString() == collectionId) {
            setState(() {
              collectName = its['name'];
            });
          }
        });
      }
      setState(() {
        collects = a;
      });
      if (types != null) {
        _pickCollect();
      } else {
        Navigator.pop(context);
      }
    }
    print(res);
  }

  List collects = [];
  List showVoteList = [];
  TextEditingController _voteController1 = TextEditingController();
  TextEditingController _voteController2 = TextEditingController();
  TextEditingController _voteController3 = TextEditingController();
  TextEditingController _voteController4 = TextEditingController();
  TextEditingController _voteController5 = TextEditingController();
  TextEditingController _voteController6 = TextEditingController();
  bool anonymity = false;
  bool watermark = true;
  @override
  void initState() {
    super.initState();
    forumNameWidget = _forumNameWidget();

    if (widget.arguments != null) {

      if (widget.arguments['str'] != null) {
        var a = widget.arguments['str'].split('|');
        forumId = a[0];
        forumName = a[1];
        forumImageName = a[2];
      }

      if (widget.arguments['fromDraft'] != null) {
        fromDraft = widget.arguments['fromDraft'];
      }
    }



    recoverDraft();

    _forumRow();
    getTagList();
    // Timer(const Duration(milliseconds: 0), () {
    //   try {
    //     _pickForum();
    //   } catch (e) {}
    // });
  }

  Widget _forumNameWidget() {
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     forumRow,
    //   ],
    // );
    return forumRow;
  }


  Future<void> recoverDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('cf_draft_article') != null) {
      _controller = QuillController(
          document: Document.fromJson(json.decode(prefs.getString('cf_draft_article'))),
          selection: TextSelection.collapsed(offset: 0));
    }

    _controller.document.changes.listen((event) {
      saveDraft();
    });
  }

  Future<void> saveDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_controller.document.toPlainText().isNotEmpty) {
      var temp = _controller.document.toDelta().toJson();
      prefs.setString('cf_draft_article', json.encode(temp));
    } else {
      prefs.remove('cf_draft_article');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 14,
              right: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: ()  async {
                    SharedPreferences prefs= await SharedPreferences.getInstance();
                    if (prefs.getString('cf_draft_article') != null) {
                      showCupertinoDialog(
                        //showCupertinoDialog
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text('??????'),
                              content: Text('?????????????????????????????????????????????????????????'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text('?????????'),
                                  onPressed: () {
                                    prefs.remove('cf_draft_article');
                                    Navigator.of(context).pop('cancel');
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('??????'),
                                  onPressed: () async {
                                    Navigator.of(context).pop('ok');
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Image.asset('assets/images/_icon/closes.png')),

              Row(
                  children:[
                    // InkWell(
                    //   onTap: debounce(() {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/draft',
                    //     );
                    //   }),
                    //   child: Container(
                    //     padding: EdgeInsets.only(
                    //       left: 16,
                    //       right: 16,
                    //       bottom: 4,
                    //       top: 4,
                    //     ),
                    //     alignment: Alignment.centerLeft,
                    //     decoration: BoxDecoration(
                    //       color: KColor.primaryColor,
                    //       borderRadius: BorderRadius.all(Radius.circular(20)),
                    //       // border: Border.all(
                    //       //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                    //     ),
                    //     child: Text(
                    //       '??????',
                    //       style: TextStyle(
                    //         fontSize: ScreenUtil().setSp(28),
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Space(width: ScreenUtil().setWidth(20),),
                    InkWell(
                      onTap: debounce(() {
                        toPush(context);
                      }),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 4,
                          top: 4,
                        ),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: KColor.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          // border: Border.all(
                          //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                        ),
                        child: Text(
                          '??????',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ]
              )
            ],
          ),
        ),
        preferredSize: Size(double.infinity, 40),
      ),
      body: Stack(
        children: [
          Container(
            width: ScreenUtil().setWidth(750),
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    _pickForum();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 20,
                      top: 5,
                      bottom: 10,
                    ),
                    color: Theme.of(context).canvasColor,
                    width: ScreenUtil().setWidth(750),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            children:[
                              _forumNameWidget(),
                              Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Color.fromRGBO(167, 165, 172, 1),
                                size: 24,
                              ),
                            ]),
                        InkWell(
                            onTap:() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChaoFunWebView(
                                    url: "https://chao.fan/webview/forum/show_rule?forumId=" + forumId,
                                    title: "????????????",
                                    showHeader: true,
                                    cookie: true,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              child:  Text(
                                "????????????",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(24),
                                    color: Theme.of(context).hintColor
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.black38,
                ),
                tagList.length != 0
                    ? Container(
                  height: 30,
                  color: Color.fromRGBO(244, 244, 245, 1),
                  width: ScreenUtil().setWidth(750),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tagList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (tagList[index]['id'].toString() == tagId) {
                            setState(() {
                              tagId = '';
                            });
                          } else {
                            setState(() {
                              tagId = tagList[index]['id'].toString();
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                            tagId == tagList[index]['id'].toString()
                                ? Color.fromRGBO(33, 29, 47, 1)
                                : Color.fromRGBO(211, 210, 214, 1),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          margin: EdgeInsets.only(
                              left: 14, top: 5, bottom: 5),
                          child: Text(
                            tagList[index]['name'],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(24),
                              color:
                              tagId == tagList[index]['id'].toString()
                                  ? Colors.white
                                  : Color.fromRGBO(33, 29, 47, 1),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  height: 0,
                ),
                TextField(
//                   focusNode: _commentFocus,
                  autofocus: true,
                  controller: _inputController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                        left: 14, top: 2, right: 14, bottom: 2),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00FF0000)),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    hintText: '???????????????' + ((postType == 'image' || postType == 'inner_video' ) ? '????????????': ''),
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000)),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),

                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (val) {},

                  onSubmitted: (term) async {
                    print(term);

                    // ????????????????????????
                  },
                  onTap:() {
                    // FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
                Expanded(
                  flex: 1,
                  child: _dealContent(),
                ), //????????????
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
              // height: ScreenUtil().setWidth(300),
              child: Column(
                children: [
                  clipboardDatas != null
                      ? Container(
                    margin: EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(4),
                    color: KColor.defaultPageBgColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            clipboardDatas,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            _linkurlController.text = clipboardDatas;

                            var url = KSet.islink(clipboardDatas);
                            FormData formdata = FormData.fromMap({
                              'url': url,
                            });
                            var res = await HttpUtil().post(
                              Api.httpurltitle,
                              parameters: {'data': formdata},
                              options: Options(
                                headers: {
                                  Headers.contentTypeHeader:
                                  'application/x-www-form-urlencoded', // set content-length
                                  Headers.acceptHeader: 'application/json'
                                },
                              ),
                            );
                            print(res);
                            _inputController.text = res['data'];
                            setState(() {
                              clipboardDatas = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              bottom: 4,
                              top: 4,
                            ),
                            // margin: EdgeInsets.only(top: 8),
                            width: ScreenUtil().setWidth(100),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(33, 29, 47, 0.05),
                              borderRadius:
                              BorderRadius.all(Radius.circular(4)),
                              // border: Border.all(
                              //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                            ),
                            child: Text(
                              '??????',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(26),
                                color: KColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              clipboardDatas = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              // left: 10,
                              // right: 10,
                              bottom: 4,
                              top: 4,
                            ),
                            margin: EdgeInsets.only(left: 4),
                            width: ScreenUtil().setWidth(100),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(33, 29, 47, 0.05),
                              borderRadius:
                              BorderRadius.all(Radius.circular(4)),
                              // border: Border.all(
                              //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                            ),
                            child: Text(
                              '??????',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(26),
                                color: KColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    height: 0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: postType == 'image',
                        child:  InkWell(
                          onTap: () {
                            setState(() {
                              if (!watermark) {
                                watermark = true;
                              } else {
                                watermark = false;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 4,
                              top: 4,
                            ),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: !watermark
                                  ? Color.fromRGBO(244, 244, 245, 1)
                                  : KColor.primaryColor,
                              borderRadius:
                              BorderRadius.all(Radius.circular(14)),
                              // border: Border.all(
                              //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: ScreenUtil().setWidth(24),
                                  height: ScreenUtil().setWidth(24),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: watermark
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                    border: Border.all(
                                        color: !watermark
                                            ? Color.fromRGBO(
                                            153, 153, 153, 0.7)
                                            : Colors.transparent,
                                        width: 1),
                                  ),
                                ),
                                Text(
                                  '??????',
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(26),
                                    color: !watermark
                                        ? Color.fromRGBO(33, 29, 47, 0.7)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 20,
                      // ),collectionlist
                      Container(width: 15,),

                      InkWell(
                        onTap: () {
                          collectionlist('1');
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // color: Color.fromRGBO(211, 210, 214, 1),
                            border: Border.all(
                              width: 1.4,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/_icon/coll.png',
                                width: ScreenUtil().setWidth(30),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                '???????????????',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                ),
                              ),
                              collectName != null
                                  ? Container(
                                child: Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                        ScreenUtil().setWidth(300),

                                        // minWidth: ScreenUtil().setWidth(200),
                                      ),
                                      child: Text(
                                        '--' + collectName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize:
                                          ScreenUtil().setSp(24),
                                          color: KColor.primaryColor,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          collectionId = '';
                                          collectName = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Text(''),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 15,),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (!anonymity) {
                              anonymity = true;
                            } else {
                              anonymity = false;
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 4,
                            top: 4,
                          ),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: !anonymity
                                ? Color.fromRGBO(244, 244, 245, 1)
                                : KColor.primaryColor,
                            borderRadius:
                            BorderRadius.all(Radius.circular(14)),
                            // border: Border.all(
                            //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: ScreenUtil().setWidth(24),
                                height: ScreenUtil().setWidth(24),
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: anonymity
                                      ? Colors.green
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                                  border: Border.all(
                                      color: !anonymity
                                          ? Color.fromRGBO(
                                          153, 153, 153, 0.7)
                                          : Colors.transparent,
                                      width: 1),
                                ),
                              ),
                              Text(
                                '??????',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(26),
                                  color: !anonymity
                                      ? Color.fromRGBO(33, 29, 47, 0.7)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                  _typeWidget(),
                ],
              ),
            ),
          ),
          isLoading
              ? Positioned(
            top: ScreenUtil().setHeight(300),
            left: ScreenUtil().setWidth(350),
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(254, 149, 0, 100)),
              ),
            ),
          )
              : Container(
            height: 0,
          ),
        ],
      ),
    );
  }


  // ????????????????????????
  deltaToHtml(Delta delta) {
    final convertedValue = jsonEncode(delta.toJson());
    final markdown = deltaToMarkdown(convertedValue);
    var html = markdownToHtml(markdown);
    html = html.replaceAll("\n", "<br>");
    html = html.replaceAll("<p>", "<p style=\"white-space:pre-wrap\">");

    // html = html.replaceAll(" ", "&nbsp;");
    return html;
  }


  Function debounce(
      Function func, [
        Duration delay = const Duration(milliseconds: 1000),
      ]) {
    Timer timer;
    Function target = () {
      if (timer?.isActive ?? false) {
        timer?.cancel();
      }
      timer = Timer(delay, () {
        func?.call();
      });
    };
    return target;
  }

  toPush(context) async {
    var title = _inputController.text;
    var response;
    if (postType == null) {
      Fluttertoast.showToast(
        msg: '?????????????????????',
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    if (forumId == null) {
      Fluttertoast.showToast(
        msg: '?????????????????????',
        gravity: ToastGravity.CENTER,
      );
      return;
    } else if (!(postType == 'image' || postType == 'inner_video' || postType == 'audio' )  && title == '') {
      Fluttertoast.showToast(
        msg: '?????????????????????????????????',
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    if (postType == 'article') {
      if (_inputController.text.trim().isNotEmpty) {
        if (canSub) {
          setState(() {
            canSub = false;
          });
          FormData formdata = null;
          try {
            formdata = FormData.fromMap({
              'anonymity': anonymity,
              'forumId': forumId,
              'title': title,
              'articleType': 'richtext',
              'article': deltaToHtml(_controller.document.toDelta()),
              'tagId': tagId,
              'collectionId': collectionId,
            });
          } catch (e) {
            setState(() {
              canSub = true;
            });
            Fluttertoast.showToast(
              msg: '??????????????????????????????????????????',
              gravity: ToastGravity.CENTER,
            );
            return;
          }
          print(_controller.document.toPlainText());
          try {
            response = await HttpUtil().post(
              Api.submitArticle,
              parameters: {'data': formdata},
              options: Options(
                headers: {
                  Headers.contentTypeHeader:
                  'application/x-www-form-urlencoded', // set content-length
                  Headers.acceptHeader: 'application/json'
                },
              ),
            );
          } catch (e) {
            _handleSubmitError();
            return;
          }

          if (response['success']) {
            SharedPreferences prefs= await SharedPreferences.getInstance();
            prefs.remove('cf_draft_article');
          }
        } else {
          Fluttertoast.showToast(
            msg: '??????????????????',
            gravity: ToastGravity.CENTER,
          );
          return;
        }
      } else {
        Fluttertoast.showToast(
          msg: '??????????????????~',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    } else if (postType == 'image') {
      if (isLoading) {
        Fluttertoast.showToast(
          msg: '???????????????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      if (canSub) {
        String img = '';
        img = imagesUrl.join(',');
        if (imagesUrl.length == 1) {
          setState(() {
            canSub = false;
          });
          try {
            response = await HttpUtil().post(Api.submitImage, queryParameters: {
              'forumId': forumId,
              'title': title,
              'ossName': img,
              'tagId': tagId,
              'anonymity': anonymity,
              'collectionId': collectionId,
              'watermark': watermark,
            });
          } catch (e) {
            _handleSubmitError();
            return;
          }
        } else if (imagesUrl.length > 1) {
          setState(() {
            canSub = false;
          });
          try {
            response = await HttpUtil().post(Api.submitImage, queryParameters: {
              'forumId': forumId,
              'title': title,
              'ossNames': img,
              'tagId': tagId,
              'anonymity': anonymity,
              'collectionId': collectionId,
              'watermark': watermark,
            });
          } catch (e) {
            _handleSubmitError();
            return;
          }
        } else {
          if (!isLoading && title != null && title != '') {
            setState(() {
              canSub = false;
            });
            FormData formdata = FormData.fromMap({
              'anonymity': anonymity,
              'forumId': forumId,
              'title': title,
              'articleType': 'richtext',
              'tagId': tagId,
              'collectionId': collectionId,
            });
            try {
              response = await HttpUtil().post(
                Api.submitArticle,
                parameters: {'data': formdata},
                options: Options(
                  headers: {
                    Headers.contentTypeHeader:
                    'application/x-www-form-urlencoded', // set content-length
                    Headers.acceptHeader: 'application/json'
                  },
                ),
              );
            } catch (e) {
              _handleSubmitError();
              return;
            }
          } else {
            Fluttertoast.showToast(
              msg: '???????????????????????????',
              gravity: ToastGravity.CENTER,
            );
            return;
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: '??????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    } else if (postType == 'inner_video') {
      if (isLoading) {
        Fluttertoast.showToast(
          msg: '???????????????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      if (canSub) {
        if (videoUrl != null) {
          setState(() {
            canSub = false;
          });
          try {
            response = await HttpUtil().get(Api.submitVideo, parameters: {
              'forumId': forumId,
              'title': title,
              'ossName': videoUrl,
              'tagId': tagId,
              'anonymity': anonymity,
              'collectionId': collectionId
            }, alterFailed: true);
          } catch (e) {
            _handleSubmitError();
            return;
          }
        } else {
          Fluttertoast.showToast(
            msg: '??????????????????????????????????????????~',
            gravity: ToastGravity.CENTER,
          );
          return;
        }
      } else {
        Fluttertoast.showToast(
          msg: '??????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    } else if (postType == 'link') {
      if (_linkurlController.text.trim().isNotEmpty) {
        if (!isLoading) {
          if (canSub) {
            setState(() {
              canSub = false;
            });
            setState(() {
              isLoading = true;
            });
            try {
              response = await HttpUtil().get(Api.submitLink, parameters: {
                'forumId': forumId,
                'title': title,
                'link': _linkurlController.text,
                'tagId': tagId,
                'anonymity': anonymity,
                'collectionId': collectionId
              });
            } catch (e) {
              _handleSubmitError();
              return;
            }
          } else {
            Fluttertoast.showToast(
              msg: '??????????????????',
              gravity: ToastGravity.CENTER,
            );
            return;
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: '???????????????~',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    } else if (postType == 'vote') {
      if (showVoteList.length > 0) {
        if (!isLoading) {
          if (canSub) {
            setState(() {
              canSub = false;
              isLoading = true;
            });
            // FormData formdata = FormData.fromMap(
            //     {'forumId': forumId, 'title': title, 'options': json.encode(voteList)});
            print('oooooooooooooo');
            print(showVoteList);
            try {
              response = await HttpUtil().post(Api.submitVote, queryParameters: {
                'forumId': forumId,
                'title': title,
                'tagId': tagId,
                'options': json.encode(showVoteList),
                'anonymity': anonymity,
                'collectionId': collectionId
              });
            } catch (e) {
              _handleSubmitError();
              return;
            }
            print(response);
          } else {
            Fluttertoast.showToast(
              msg: '??????????????????',
              gravity: ToastGravity.CENTER,
            );
            return;
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: '?????????????????????~',
          gravity: ToastGravity.CENTER,
        );
        _pickVote();
      }
    }  else if (postType == 'audio') {
      if (isLoading) {
        Fluttertoast.showToast(
          msg: '???????????????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      if (canSub) {
        if (audioUrl != null) {
          setState(() {
            canSub = false;
          });
          try {
            response = await HttpUtil().get(Api.submitAudio, parameters: {
              'forumId': forumId,
              'title': title,
              'ossName': audioUrl,
              'tagId': tagId,
              'anonymity': anonymity,
              'collectionId': collectionId
            });
          } catch (e) {
            _handleSubmitError();
            return;
          }
        } else {
          Fluttertoast.showToast(
            msg: '?????????????????????~',
            gravity: ToastGravity.CENTER,
          );
          return;
        }
      } else {
        Fluttertoast.showToast(
          msg: '??????????????????',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
    }


    if (response['success']) {
      setState(() {
        isLoading = false;
      });
      Provider.of<UserStateProvide>(context, listen: false)
          .setRemmenberForumList(
          {'id': forumId, 'name': forumName, 'imageName': forumImageName});
      Fluttertoast.showToast(
        msg: '????????????',
        gravity: ToastGravity.CENTER,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        canSub = true;
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: response['errorMessage'].toString(),
        gravity: ToastGravity.CENTER,
      );
    }
  }
  _handleSubmitError() {
    Fluttertoast.showToast(
      msg: '?????????????????????????????????',
      gravity: ToastGravity.CENTER,
    );
    setState(() {
      canSub = false;
    });
    return;
  }

  _dealContent() {
    // if (postType != null) {
    switch (postType) {
      case 'article':
        return _articleWidget();
        break;
      case 'image':
        return _imageWidget();
        break;
      case 'inner_video':
        return _videoWidget();
        break;
      case 'audio':
        return _audioWidget();
        break;
      case 'link':
        return _linkWidget();
        break;
      case 'vote':
        return _voteWidget();
        break;
      default:
        return Container(
          height: 0,
        );
    }
    // }
  }

  _voteWidget() {
    if (showVoteList.length != 0) {
      return Container(
        height: 80,
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                _pickVote();
              },
              child: Container(
                margin: EdgeInsets.all(14),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  border: Border.all(
                    width: 0.5,
                    color: Color.fromRGBO(230, 230, 230, 1),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  primary:
                  false, //false????????????????????????????????????????????? ?????????[primary]???true????????????????????????????????????
                  shrinkWrap: true, // ????????????
                  itemCount: showVoteList.length,
                  itemBuilder: (c, i) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0x30cccccc),
                        border: Border.all(
                          width: 0.5,
                          color: Color.fromRGBO(230, 230, 230, 1),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      margin: EdgeInsets.only(bottom: 4, top: 4),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      height: ScreenUtil().setWidth(70),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        showVoteList[i]['optionName'],
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: -2,
              right: 6,
              child: InkWell(
                onTap: () {
                  var length = voteList.length;
                  for (var k = 0; k < length; k++) {
                    _doController(k + 1).text = '';
                  }
                  setState(() {
                    showVoteList = [];
                    voteList = [
                      {'optionName': ''},
                      {'optionName': ''},
                    ];
                  });
                },
                child: Icon(Icons.cancel_rounded),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Future<String> _onImagePickCallback(File image) async {

    setState(() {
      isLoading = true;
    });
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });

    Dio dio = new Dio();
    var response =
    await dio.post("https://chao.fan/api/upload_image", data: formdata);
    print('????????????');
    print(response);
    print(response.data['data']);
    setState(() {
      isLoading = false;
    });
    if (response.data['success']) {
      return KSet.imgOrigin + response.data['data'];
    } else {
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
      return null;
    }
  }

  _articleWidget() {


    return Column(
      children: [
        QuillToolbar.basic(
          controller: _controller,
          onImagePickCallback: _onImagePickCallback,
          showFontSize: false,
          showDividers: false,
          showCenterAlignment: false,
          showRedo: false,
          showUndo: false,
          showItalicButton: false,
          showInlineCode: false,
          showUnderLineButton: false,
          showListNumbers: false,
          showJustifyAlignment: false,
          showIndent: true,
          showListCheck: false,
          multiRowsDisplay: true,
          showVideoButton: false,
          showCameraButton: false,
          showColorButton: false,
          showStrikeThrough: false,
          showBackgroundColorButton: false,
          showClearFormat: true,
        ),
        Visibility(
          visible: Platform.isAndroid,
          child: Text('????????????????????????????????????????????????????????????????????????', style: TextStyle(color: Theme.of(context).hintColor, fontSize: ScreenUtil().setWidth(20)),),
        ),
        Expanded(
          flex: 15,
          child:
          Container(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 70),
              child: QuillEditor(
                placeholder: '????????????(??????)',
                controller: _controller,
                scrollController: _scrollController,
                scrollable: true,
                focusNode: _focusNode,
                autoFocus: true,
                readOnly: false,
                expands: true,
                padding: EdgeInsets.zero,
              )
          ),
          // ),
        )
      ],
    );
  }

  _linkWidget() {
    return Column(
      children: [
        TextField(
          autofocus: false,
          controller: _linkurlController,
          maxLines: 10,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
            EdgeInsets.only(left: 14, top: 0, right: 14, bottom: 0),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x00FF0000)),
            ),
            hintText: '?????????????????????',
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x00000000)),
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            // fontWeight: FontWeight.bold,
          ),
          onChanged: (val) {},
          onSubmitted: (term) async {
            print(term);

            // ????????????????????????
          },
        ),
      ],
    );
  }

  _imageWidget() {
    return InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          // color: Color.fromRGBO(95, 60, 94, 1),
          padding: EdgeInsets.only(top: 4, left: 0, right: 0),
          // height: ScreenUtil().setWidth((716)),
          constraints: BoxConstraints(
            minHeight: ScreenUtil().setWidth(140),
          ),
          child: GridView.builder(
            padding: EdgeInsets.only(left: 10, right: 10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: ScreenUtil().setWidth(12),
              crossAxisSpacing: ScreenUtil().setWidth(12),
              // childAspectRatio: 1.5,
            ),
            physics: NeverScrollableScrollPhysics(),
            itemCount: imageList.length < 9 ? imageList.length + 1 : 9,
            itemBuilder: (context, index) {
              if (index == imageList.length && imageList.length != 9) {
                return InkWell(
                  onTap: () {
                    // _pickImage();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(228),
                    height: ScreenUtil().setWidth(228),
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   width: 1,
                      //   color: Color.fromRGBO(224, 224, 224, 0.7),
                      // ),
                      image: DecorationImage(
                        // image: AssetImage("assets/??????/bg1.jpg"),
                        image: AssetImage(
                          'assets/images/_icon/add_2.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            getImage(true);
                          },
                          child: Container(
                            width: double.infinity,
                            height: ScreenUtil().setWidth(114),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: KColor.primaryColor,
//                          borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Color.fromRGBO(153, 153, 153, 0.3),
                                  width: 0.5),
                            ),
                            child: Text(
                              '??????',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(34),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
//                    SizedBox(
//                      height: 14,
//                    ),
                        InkWell(
                          onTap: () {
                            getImage(false);
                          },
                          child: Container(
                            width: double.infinity,
                            height: ScreenUtil().setWidth(114),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: KColor.primaryColor,
//                          borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Color.fromRGBO(153, 153, 153, 0.3),
                                  width: 0.5),
                            ),
                            child: Text(
                              '??????',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(34),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Color.fromRGBO(211, 210, 214, 1),
                            border: Border.all(
                              width: 0.5,
                              color: Color.fromRGBO(211, 210, 214, 1),
                            ),
                            // borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Image.file(
                            File(imageList[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isLoading = false;
                              imageList.removeAt(index);
                              imagesUrl.removeAt(index);
                            });
                          },
                          child: Image.asset(
                            'assets/images/_icon/s_close.png',
                            width: ScreenUtil().setWidth(34),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        )
    );
  }

  var recording = false;
  Record myRecorder = null;
  _audioWidget() {
    return Container(
        alignment: Alignment.topLeft,
        child: TextButton(onPressed: () async {
          if (audioUrl != null) {
            setState(() {
              audioUrl = null;
            });
          }

          if (isLoading) {
            Fluttertoast.showToast(
              msg: '???????????????????????????',
              gravity: ToastGravity.CENTER,
            );
            return;
          }
          if (myRecorder == null) {
            myRecorder = Record();
            bool result = await myRecorder.hasPermission();
            if (result) {
              setState(() {
                isRecording = true;
              });
              var tempDir = await getTemporaryDirectory();
              await myRecorder.start(
                path: tempDir.path + '/myFile.aac', // required
                encoder: AudioEncoder.AAC, // by default
                bitRate: 128000, // by default
                samplingRate: 44100, // by default
              );
            }
          } else {
            var uri =  await myRecorder.stop();
            myRecorder = null;
            setState(() {
              isRecording = false;
              isLoading = true;
            });
            print(uri);
            print(await File(uri).length());
            FormData formdata = FormData.fromMap({
              "file": await MultipartFile.fromFile(uri),
              "fileName": 'myFile.aac'
            });

            duration = await (new AudioPlayer()).setFilePath(uri);
            setState(() {});

            var response = await dio.post("https://chao.fan/api/upload_audio", data: formdata);
            setState(() {
              isLoading = false;
            });

            if (response.data['success']) {
              setState(() {
                audioUrl = response.data['data'];
              });
            }
          }
        }, child:
        Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 8,
              top: 20,
            ),
            // height: ScreenUtil().setWidth(100),
            child: Text(getAudioText())
        )
        )
    );
  }

  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String getAudioText() {
    if (audioUrl != null) {
      return  twoDigits((duration.inSeconds / 60).toInt()) + ':' + twoDigits((duration.inSeconds % 60).toInt()) +  " ????????? / ??????????????????";
    } else {
      if (isRecording) {
        return "?????????... / ??????????????????";
      } else {
        if (isLoading) {
          return twoDigits((duration.inSeconds / 60).toInt()) + ':' + twoDigits((duration.inSeconds % 60).toInt()) +  " ?????????... / ?????????";
        } else {
          return "????????????";
        }
      }
    }
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  _videoWidget() {
    if (assetsVideo == null) {
      return InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            // color: Color.fromRGBO(95, 60, 94, 1),
            padding: EdgeInsets.only(top: 4, left: 10, right: 10),
            // width: ScreenUtil().setWidth(250),
            // height: ScreenUtil().setWidth(250),
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                width: ScreenUtil().setWidth(228),
                height: ScreenUtil().setWidth(228),
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   width: 1,
                  //   color: Color.fromRGBO(224, 224, 224, 0.7),
                  // ),
                  image: DecorationImage(
                    // image: AssetImage("assets/??????/bg1.jpg"),
                    image: AssetImage(
                      'assets/images/_icon/add_2.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                // child: Image.asset(
                //   'assets/images/_icon/Add@2x.png',
                //   fit: BoxFit.cover,
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        getVideo(true);
                      },
                      child: Container(
                        width: double.infinity,
                        height: ScreenUtil().setWidth(114),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // color: KColor.primaryColor,
//                      borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              color: Color.fromRGBO(153, 153, 153, 0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          '??????',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(34),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        getVideo(false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: ScreenUtil().setWidth(114),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // color: KColor.primaryColor,
//                      borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              color: Color.fromRGBO(153, 153, 153, 0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          '??????',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(34),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      );
    } else {
      return Container(
        alignment: Alignment.topLeft,
        // height: ScreenUtil().setWidth(200),
        child: Column(
          children: [

            totals != null
                ? Container(
              height: ScreenUtil().setWidth(100),
              width: ScreenUtil().setWidth(750),
              // color: Colors.blue,
              alignment: Alignment.center,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        //????????????????????????
                        height: 10.0,
                        //????????????????????????
                        width: ScreenUtil().setWidth(600),
                        child: new LinearProgressIndicator(
                          //0~1???????????????????????????????????????;?????? value ??? null ?????????????????????????????????????????????????????????
                            value:
                            double.parse(percent.toStringAsFixed(2)),
                            //????????????
                            backgroundColor:
                            Color.fromRGBO(240, 240, 240, 1),
                            //????????????
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.green)),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      child: Text(
                        '???????????????-' +
                            totals +
                            'M (' +
                            (percent * 100).toStringAsFixed(1) +
                            '%)\n??????100%??????????????????????????????????????????',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil().setSp(26)),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(
              height: 0,
            ),
            totals == null
                ? InkWell(
              onTap: () {
                setState(() {
                  assetsVideo = null;
                });
                _pickImage();
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 8,
                  top: 8,
                ),
                margin: EdgeInsets.only(top: 8),
                width: ScreenUtil().setWidth(180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(33, 29, 47, 0.05),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  // border: Border.all(
                  //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                ),
                child: Text(
                  '????????????',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: KColor.primaryColor,
                  ),
                ),
              ),
            )
                : Text(''),
            Container(
              height: ScreenUtil().setWidth(450),
              color: Colors.black,
              child: VideoWidget(
                  item: {'video': assetsVideo},
                  video: true,
                  detail: true,
                  isAssets: true),
            ),
          ],
        ),
      );
    }
  }

  // ????????????
  _pickCollect() {
//    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(builder: (c, setBottomSheetState) {
        return Container(
          height: ScreenUtil().setWidth(750),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30),
                ),
                height: ScreenUtil().setWidth(70),
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '????????????',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push<String>(context, new MaterialPageRoute(
                            builder: (BuildContext context) {
                              return new CollectAddPage();
                            })).then((String result) {
                          //????????????
                          print(result);
                          if (result != null) {
                            setBottomSheetState(() {
                              collectionId = result;
                              collects = [];
                            });
                            collectionlist(null);
                          }
                        });
                      },
                      child: Text(
                        '????????????',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: Color.fromRGBO(53, 140, 255, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: collects.length > 0
                    ? Container(
                  // height: ScreenUtil().setWidth(500),
                  // color: Colors.white,
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(30),
                    right: ScreenUtil().setWidth(30),
                    top: ScreenUtil().setWidth(20),
                  ),
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: InkWell(
                          onTap: () async {
                            setBottomSheetState(() {
                              collectionId =
                                  collects[index]['id'].toString();
                              collectName = collects[index]['name'];
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: ScreenUtil().setWidth(100),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.8,
                                  color: KColor.defaultBorderColor,
                                ),
                              ),
                            ),
                            child: Text(
                              collects[index]['name'],
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(30),
                              ),
                            ),
                            // color: Colors.primaries[(index) % Colors.primaries.length],
                          ),
                        ),
                      );
                    },
                    itemCount: collects.length,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/_icon/nodata.png'),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '????????????',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ????????????
  _pickImage() {
    print("_pickImage");
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setWidth(350),
        color: Color.fromRGBO(245, 245, 245, 1),
        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () async {
                  print(postType);
                  if (postType == 'image') {
                    switch (index) {
                      case 0:
                        getImage(true);
                        break;
                      case 1:
                        getImage(false);
                        break;
                    }
                  } else {
                    switch (index) {
                      case 0:
                        getVideo(true);
                        break;
                      case 1:
                        getVideo(false);
                        break;
                    }
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  height: ScreenUtil().setWidth(100),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        postType == 'image'
                            ? picks[index]['title']
                            : picksVideo[index]['title'],
                        style: TextStyle(
                          // color: _doColor(index),
                        ),
                      )
                    ],
                  ),
                  // color: Colors.primaries[(index) % Colors.primaries.length],
                  color: Colors.white,
                ),
              ),
            );
          },
          itemCount: 2,
        ),
      ),
    );
  }

  // ????????????
  _pickForum() {

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ForumListPage(callBack: callBack),
    ));
    // FocusScope.of(context).requestFocus(FocusNode());


    // ???????????????????????????????????????????????????
    // showModalBottomSheet(
    //   isScrollControlled: true,
    //   context: this.context,
    //   builder: (context) => AnimatedPadding(
    //     // padding: MediaQuery.of(context).viewInsets, //??????????????????
    //     padding: EdgeInsets.only(
    //       bottom: MediaQuery.of(context).viewInsets.bottom,
    //       top: MediaQuery.of(context).viewInsets.top + 20,
    //       left: ScreenUtil().setWidth(10),
    //       right: ScreenUtil().setWidth(10),
    //     ),
    //     duration: const Duration(milliseconds: 100), //?????? ????????????
    //     child: ForumListPage(callBack: callBack),
    //   ),
    // );
  }

  callBack(result) async {
    if (result != null) {
      var a = result.split('|');
      setState(() {
        forumId = a[0];
        forumName = a[1];
        forumImageName = a[2];
        tagId = '';
      });
      _forumRow();
      var response =
      await HttpUtil().get(Api.listTag, parameters: {'forumId': forumId});
      print('ksssssss');
      print(response);
      if (response['success'] == true) {
        setState(() {
          tagList = response['data'];
        });
      }
    }
    Navigator.pop(context);
  }

  // ????????????
  _pickVote() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(builder: (c, setBottomSheetState) {
        return AnimatedPadding(
          // padding: MediaQuery.of(context).viewInsets, //??????????????????
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: ScreenUtil().setWidth(10),
            left: ScreenUtil().setWidth(10),
            right: ScreenUtil().setWidth(10),
          ),
          duration: const Duration(milliseconds: 100), //?????? ????????????
          child: Container(
            height: ScreenUtil().setWidth(750),
            child: Stack(
              children: [
                Container(
                  // height: ScreenUtil().setWidth(350),
                  color: Color.fromRGBO(245, 245, 245, 1),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  width: ScreenUtil().setWidth(750),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text('??????'),
                          InkWell(
                            onTap: () {
                              var showVotes = [];
                              var length = voteList.length;
                              for (var k = 0; k < length; k++) {
                                voteList[k]['optionName'] =
                                    _doController(k + 1).text;
                              }
                              bool can = true;
                              voteList.forEach((element) {
                                if (!(element['optionName']
                                    .trim()
                                    .isNotEmpty)) {
                                  can = false;
                                } else {
                                  showVotes.add(element);
                                }
                              });
                              print('???????????????');
                              print(voteList);
                              setBottomSheetState(() {
                                voteList = voteList;
                              });
                              setState(() {
                                showVoteList = showVotes;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              '??????',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: KColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      _voteInput(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 4,
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(30),
                  child: InkWell(
                    onTap: () async {
                      if (voteList.length < 6) {
                        setBottomSheetState(() {
                          voteList.add({'optionName': ''});
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        // left: 10,
                        // right: 10,
                        bottom: 4,
                        top: 4,
                      ),
                      // margin: EdgeInsets.only(top: 8),
                      height: ScreenUtil().setWidth(74),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: voteList.length == 6
                            ? Color.fromRGBO(153, 153, 153, 1)
                            : Color.fromRGBO(33, 29, 47, 1),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        // border: Border.all(
                        //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                      ),
                      child: Text(
                        '??????????????????',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ????????????
  Widget _voteInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 0),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        primary: false, //false????????????????????????????????????????????? ?????????[primary]???true????????????????????????????????????
        shrinkWrap: true, // ????????????
        itemCount: voteList.length,
        itemBuilder: (c, i) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            height: ScreenUtil().setWidth(70),
            child: Stack(
              children: [
                TextField(
                  controller: _doController(i + 1),
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  decoration: InputDecoration(
                    hoverColor: Color.fromRGBO(240, 240, 240, 1),
                    hintText: "???????????????" + (i + 1).toString(),
                    hintStyle: TextStyle(color: Colors.grey),
                    // filled: true,
                    // fillColor: Color.fromRGBO(244, 244, 245, 1),
                    fillColor: Color(0x30cccccc),
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.transparent, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.transparent, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _doController(i) {
    switch (i) {
      case 1:
        return _voteController1;
        break;
      case 2:
        return _voteController2;
        break;
      case 3:
        return _voteController3;
        break;
      case 4:
        return _voteController4;
        break;
      case 5:
        return _voteController5;
        break;
      case 6:
        return _voteController6;
        break;
    }
  }

  Future getImage(isTakePhoto) async {
    FocusScope.of(context).requestFocus(FocusNode());
    List image;
    // if (chooseType == null || chooseType == 'image') {
    // Navigator.pop(context);
    if (isTakePhoto) {
      // var ims = await ImagePicker.pickImage(
      //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
      // TODO[cijian]: ????????????????????????
      var ims = await ImagesPicker.openCamera(
        pickType: PickType.image, //quality: 0.8, maxSize: 20480
        // maxTime: 15, // record video max time
      );
      print(ims); //image/jpeg [Instance of 'Media']

      setState(() {
        imageList.addAll(ims.map((e) {
          return File(e.path);
        }).toList());
        imagesUrl.addAll(new List(ims.length));
        canSub = false;
        isLoading = true;
      });

      for (var i = (imageList.length - ims.length); i < imageList.length; i++) {
        _upLoadImage(imageList[i], i);
      }
    } else {
      final List<AssetEntity> result = await AssetPicker.pickAssets(context, pickerConfig: AssetPickerConfig(maxAssets: 9 - imageList.length, requestType: RequestType.image));

      if (result != null && result.length > 0) {
        for (int i = 0; i < result.length; i ++) {

        }
        for (int i = 0; i < result.length; i ++) {
          File imgFile = await result[i].file;
          imageList.add(imgFile);
        }
        setState(() {
          // imageList.addAll(result.map((e) {
          //   return e.file(); // Your `File` object
          //   // return File(e.relativePath);
          // }).toList());
          imagesUrl.addAll(new List(result.length));
          canSub = false;
          isLoading = true;
        });
        for (var i = (imageList.length - result.length); i < imageList.length; i++) {
          _upLoadImage(imageList[i], i);
        }
      }
    }
    // }
  }

  Future getVideo(isTakeVideo) async {
    // if (chooseType == null || chooseType == 'video') {
    // Navigator.pop(context);
    if (isTakeVideo) {
      // var ims = await ImagePicker.pickImage(
      //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
      var ims = await ImagesPicker.openCamera(
        pickType: PickType.video,
        maxTime: 100000, // record video max time
      );
      print('????????????');
      _upLoadVideo(File(ims[0].path));
      setState(() {
        assetsVideo = ims[0].path;
      });
    } else {
      // if (Platform.isIOS) {
      final List<AssetEntity> result = await AssetPicker.pickAssets(context, pickerConfig: AssetPickerConfig(maxAssets: 1, requestType: RequestType.video));

      if (result != null && result.length > 0) {
        File file = await result[0].file;
        _upLoadVideo(file);
        setState(() {
          assetsVideo = file.path;
        });
      }

        // final File file = File(res.path);

    }
    // }
  }

  //????????????
  _upLoadImage(File image, int i) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });

    Dio dio = new Dio();
    var response =
    await dio.post("https://chao.fan/api/upload_image", data: formdata);
    print('????????????');
    print(response);
    print(response.data['data']);
    if (response.data['success']) {
      setState(() {
        if (chooseType == null) {
          chooseType = 'image';
        }
        imagesUrl[i] = response.data['data'];
      });
    } else {
      setState(() {
        isLoading = false;
        imageList.removeAt(i);
        imagesUrl.removeAt(i);
      });
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
    int count = 0;
    for (int i = 0 ; i < imageList.length; i++) {
      if (imagesUrl[i] == null) {
        count ++;
      }
    }
    if (count == 0) {
      setState(() {
        isLoading = false;
        canSub = true;
      });
    }
  }

  _upLoadVideo(File video) async {
    String path = video.path;
    print('??????????????????');
    print(path);
    var name =
    path.substring(path.lastIndexOf("/") + 1, path.length).toLowerCase();
    print(name);
    if (name.endsWith(".jpg") ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      Fluttertoast.showToast(
        msg: "??????????????????",
        gravity: ToastGravity.CENTER,
      );
    }

    var applyResponse = await HttpUtil().get(Api.applyVideoUpload, parameters: {'fileName': name});

    print(applyResponse);

    // FormData formdata = FormData.fromMap({
    //   "data": await File.fromFile(path, filename: name).b,
    // });
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = '';
    dio.options.headers['content-length'] = await new File(path).length();
    try {
      await dio.put(applyResponse['data']['uploadUrl'], data: new File(path).openRead(), onSendProgress: (int count, int total) {
            print('progress: ${(count / total * 100).toStringAsFixed(0)}% ($count/$total)');

            if (total != null) {
              if (totals == null) {
                setState(() {
                  totals = (total / (1024 * 1024)).toStringAsFixed(2);
                });
              }
              setState(() {
                counts = (count / (1024 * 1024)).toStringAsFixed(2);
                percent = (count / total);
              });
            }
            print('count $count');
            print('total $total');
            print('percent $percent');
          });
    } catch (e) {
      Fluttertoast.showToast(
        msg: '??????????????????????????????????????????',
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    print('????????????');
    videoUrl = applyResponse['data']['ossName'];
    setState(() {
      totals = null;
      if (chooseType == null) {
        chooseType = 'video';
      }
    });
  }


  getTagList() async {
    var response =
    await HttpUtil().get(Api.listTag, parameters: {'forumId': forumId});
    print('ksssssss');
    print(response);
    if (response['success']) {
      setState(() {
        tagList = response['data'];
      });
    }
  }

  _forumRow() {
    if (forumId == null) {
      setState(() {
        forumRow = Row(
          children: [
            // Container(
            //   width: ScreenUtil().setWidth(34),
            //   height: ScreenUtil().setWidth(34),
            //   alignment: Alignment.center,
            //   color: KColor.primaryColor,
            //   child: Text(
            //     '#',
            //     style: TextStyle(
            //         color: Colors.white, fontSize: ScreenUtil().setSp(24)),
            //   ),
            // ),
            // SizedBox(
            //   width: 5,
            // ),
            Text(
              '????????????',
              style: TextStyle(fontSize: ScreenUtil().setSp(28)),
            ),
          ],
        );
      });
    } else {
      setState(() {
        forumRow = Row(
          children: [
            CachedNetworkImage(
              imageUrl: KSet.imgOrigin +
                  forumImageName +
                  '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              forumName,
              style: TextStyle(fontSize: ScreenUtil().setSp(32)),
            ),
          ],
        );
      });
    }
  }

  Widget _typeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: typesList.map((e) {
        return InkWell(
          onTap: () async {
            if (postType != e['type']) {
              setState(() {
                postType = e['type'];
                clipboardDatas = null;
              });
//              FocusScope.of(context).requestFocus(FocusNode());
              if (postType == 'link' && _linkurlController.text == '') {
                ClipboardData data =
                await Clipboard.getData(Clipboard.kTextPlain);

                if (data != null && KSet.islink(data.text) != '') {
                  setState(() {
                    clipboardDatas = KSet.islink(data.text);
                  });
                }
              } else if (postType == 'image') {
                // _pickImage();
//                getImage(false);
              } else if (postType == 'inner_video') {
                setState(() {
                  assetsVideo = null;
                });
//                getVideo(false);
                // _pickImage();
              } else if (postType == 'vote') {
                _pickVote();
              }
            }
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 2,
                bottom: MediaQuery.of(context).padding.bottom + 2),
            margin: EdgeInsets.only(top: 2),
            child: Column(
              children: [
                Image.asset(
                  postType == e['type'] ? e['actIcon'] : e['icon'],
                  width: ScreenUtil().setWidth(64),
                ),
                // Text(
                //   e['label'],
                //   style: TextStyle(fontSize: ScreenUtil().setSp(26)),
                // ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
