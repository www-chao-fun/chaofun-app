import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/set.dart';

import 'image_view.dart';

///封装之后的拍一拍效果[ShakeView]
class MsgAvatar extends StatefulWidget {
  final Map<String, dynamic> model;

  MsgAvatar({
    @required this.model,
  });

  _MsgAvatarState createState() => _MsgAvatarState();
}

class _MsgAvatarState extends State<MsgAvatar> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  initState() {
    super.initState();
    start(true);
  }

  start(bool isInit) {
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = TweenSequence<double>([
      //使用TweenSequence进行多组补间动画
      TweenSequenceItem<double>(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem<double>(tween: Tween(begin: 10, end: 0), weight: 1),
      TweenSequenceItem<double>(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem<double>(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(controller);
    if (!isInit) controller.forward();
  }

  Widget build(BuildContext context) {
    return new InkWell(
      child: AnimateWidget(
        animation: animation,
        child: new Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          margin: EdgeInsets.only(right: 10.0),
          child: new ImageView(
            img:  widget.model['sender']['icon'] == null ?  'https://i.chao.fun/biz/08a2d3a676f4f520cb99910496e48b4e.png?x-oss-process=image/resize,h_80/format,webp/quality,q_75' :  KSet.imgOrigin +
                widget.model['sender']['icon'] +
                '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
            height: 35,
            width: 35,
            fit: BoxFit.cover,
          ),
        ),
      ),
      onDoubleTap: () {
        setState(() => start(false));
      },
      onTap: () {
        print("msg_avatar tap");
        print("widget.model: " + widget.model.toString());
        Navigator.pushNamed(
          context,
          '/userMemberPage',
          arguments: {"userId": widget.model['sender']['userId'].toString()},
        );
      },
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimateWidget extends AnimatedWidget {
  final Widget child;

  AnimateWidget({
    Animation<double> animation,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    var result = Transform(
      transform: Matrix4.rotationZ(animation.value * pi / 180),
      alignment: Alignment.bottomCenter,
      child: new ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: child,
      ),
    );
    return result;
  }
}
