import 'package:flutter/material.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';

class ContentWidget extends StatelessWidget {
  List<Map> pageData;
  ContentWidget({Key key, this.pageData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _list();
  }

  _list() {
    // List<Widget> listWidget = hotGoodsList.map((val) {
    if (pageData.length != 0) {
      List<Map> arr = [];
      // pageData.forEach((v) {
      //   if (v['type'] == 'image' || v['type'] == 'link') {
      //     arr.addAll([v]);
      //   }
      // });
      List<Widget> listWidget = pageData.map((item) {
        return ItemIndex(item: item, type: 'user');
      }).toList();
      return Column(
        children: listWidget,
      );
    }
  }
}
