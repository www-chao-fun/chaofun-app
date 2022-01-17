import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class OrderPage extends StatefulWidget {
//   final String orderState;
//   OrderPage({Key key, this.orderState}) : super(key: key);
//   _OrderPageState createState() => _OrderPageState();
// }

// class _OrderPageState extends State<OrderPage> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   void hhh(){}

//   // var orderState;
//   // OrderPage({Key key, @required this.orderState}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     // final String photo = ModalRoute.of(context).settings.arguments;
//     print(orderState);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('我的订单'),
//       ),
//       body: Center(
//         child: Text('111'),
//       ),
//     );
//   }
// }

class OrderPage extends StatefulWidget {
  // OrderPage({Key key}) : super(key: key);
  var orderState;
  OrderPage({Key key, this.orderState}) : super(key: key);
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  var orderState;
  @override
  void initState() {
    super.initState();
    orderState = widget.orderState;
    print('首页刷新了...');
  }

  // void getOrder() {
  //   print(widget.orderState);
  // }

  @override
  Widget build(BuildContext context) {
    final Map orderState = ModalRoute.of(context).settings.arguments;
    // if (this.orderState == null) {
    //   this.orderState = orderState['orderState'];
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text('我的订单'),
      ),
      body: Stack(
        children: <Widget>[
          // Container(
          //   margin: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(80), 0, 0),
          //   padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
          //   child: ListView(
          //       children: this._orderList.map((value) {
          //     return InkWell(
          //       onTap: () {
          //         Navigator.pushNamed(context, '/orderinfo');
          //       },
          //       child: Card(
          //         child: Column(
          //           children: <Widget>[
          //             ListTile(
          //               title: Text("订单编号：123123123",
          //                   style: TextStyle(color: Colors.black54)),
          //             ),
          //             Divider(),
          //             Column(
          //               children: this._orderItemWidget(value.orderItem),
          //             ),
          //             SizedBox(height: 10),
          //             ListTile(
          //               leading: Text("合计：￥12"),
          //               trailing: FlatButton(
          //                 child: Text("申请售后"),
          //                 onPressed: () {},
          //                 color: Colors.grey[100],
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   }).toList()),
          // ),

          Positioned(
            top: 0,
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(76),
            child: Container(
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(76),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setOrderState('0');
                      },
                      child: Text(
                        "全部",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: this.orderState == '0'
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setOrderState('1');
                      },
                      child: Text(
                        "待付款",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: this.orderState == '1'
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setOrderState('2');
                      },
                      child: Text(
                        "待收货",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: this.orderState == '2'
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setOrderState('3');
                      },
                      child: Text(
                        "已完成",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: this.orderState == '3'
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setOrderState('4');
                      },
                      child: Text(
                        "待收货",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: this.orderState == '4'
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  setOrderState(state) async {
    setState(() {
      this.orderState = state;
    });
  }

  //自定义商品列表组件

  List<Widget> _orderItemWidget(orderItems) {
    List<Widget> tempList = [];
    for (var i = 0; i < orderItems.length; i++) {
      tempList.add(Column(
        children: <Widget>[
          SizedBox(height: 10),
          ListTile(
            leading: Container(
              width: ScreenUtil().setWidth(120),
              height: ScreenUtil().setHeight(120),
              child: Image.network(
                'http://oss.meibbc.com/bbcshop_oos/file/20200306/normal/C0DD8EC0C4DA4CAA9295B7F428768FFB.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            title: Text("商品名称"),
            trailing: Text('x3'),
          ),
          SizedBox(height: 10)
        ],
      ));
    }
    return tempList;
  }
}
