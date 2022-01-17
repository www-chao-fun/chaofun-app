import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PreviewPage extends StatelessWidget {
  final widge = [
    'http://oss.meibbc.com/BeautifyBreast/file/images/bd8afefecfe0479fbd2998fbf16bb57a.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/4a4af9f4b5cf47e782e3a35c5b9d6400.PNG?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/aec54777d2f74843803d4a5956ccb153.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/bd8afefecfe0479fbd2998fbf16bb57a.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/4a4af9f4b5cf47e782e3a35c5b9d6400.PNG?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/aec54777d2f74843803d4a5956ccb153.png?x-oss-process=style/800x800',
  ];

  @override
  Widget build(BuildContext context) {
    final Map photo = ModalRoute.of(context).settings.arguments;
    print(photo);
    // final initialIndex = photo;
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          // imageProvider: AssetImage(
          //     'https://oss.meibbc.com/gw/img/302C762BB7164670855A536DE64BD5F0.png'),
          imageProvider: NetworkImage(widge[index]),
          initialScale: PhotoViewComputedScale.contained * 0.8,
          // heroTag: widget.photoList[index]['id'],
        );
      },
      itemCount: widge.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(254, 149, 0, 100)),
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      // backgroundDecoration: widget.backgroundDecoration,
      pageController: PageController(initialPage: photo['index']),
      // onPageChanged: onPageChanged,
    ));
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Text('hello'),
  //     ),
  //   );
  // }
}
