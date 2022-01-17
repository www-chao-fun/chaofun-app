import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String img;
  final double width;
  final double height;
  final BoxFit fit;
  final bool isRadius;

  ImageView({
    @required this.img,
    this.height,
    this.width,
    this.fit,
    this.isRadius = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = new CachedNetworkImage(
        imageUrl: img,
        width: width,
        height: height,
        fit: fit,
      );

    return image;
  }
}
