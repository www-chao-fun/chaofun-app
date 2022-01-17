import '../service/http_servicenew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

class CategoryPage extends StatefulWidget {
  _CategoryPageState createState() => _CategoryPageState();
  // State<StatefulWidget> createState() => _HomePageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      appBar: AppBar(
        title: Text('商家推荐'),
      ),
      body: FutureBuilder(
        future: request('sellRecommendList'),
        builder: (context, snapshot) {
          //
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            List<Map> sellerList = (data['data'] as List).cast();
            return Container(
              // color: Colors.grey,
              padding: EdgeInsets.all(10.0),
              child: ListView(
                children: sellerList.map((item) {
                  return _gridViewItemUI(context, item);
                }).toList(),
              ),
              // Column(
              //   children: sellerList.map((item) {
              //     return _gridViewItemUI(context, item);
              //   }).toList(),
              // ),
            );
          } else {
            // print('返回空的');
          }
        },
      ),
    );
  }

  Widget _gridViewItemUI(contxt, item) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['shop_logo'],
                    fit: BoxFit.cover,
                    width: ScreenUtil().setWidth(80),
                    height: ScreenUtil().setHeight(80),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item['shop_name']),
                    Container(
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setHeight(40),
                      child: new RaisedButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {},
                        child: Text('进入'),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 10, bottom: 10.0, right: 10.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) {
                          //     return GoodsDetailPage(
                          //         goodsId: item['goods_list'][0]['goods_id']);
                          //   }),
                          // );
                        },
                        child: Image.network(
                          item['goods_list'][0]['small'],
                          width: ScreenUtil().setWidth(220),
                          height: ScreenUtil().setHeight(220),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) {
                          //     return GoodsDetailPage(
                          //         goodsId: item['goods_list'][1]['goods_id']);
                          //   }),
                          // );
                        },
                        child: Image.network(
                          item['goods_list'][1]['small'],
                          width: ScreenUtil().setWidth(220),
                          height: ScreenUtil().setHeight(220),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) {
                          //     return GoodsDetailPage(
                          //         goodsId: item['goods_list'][2]['goods_id']);
                          //   }),
                          // );
                        },
                        child: Image.network(
                          item['goods_list'][2]['small'],
                          width: ScreenUtil().setWidth(220),
                          height: ScreenUtil().setHeight(220),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
