import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class NetworkPage extends StatefulWidget {
  NetworkPage({Key key}) : super(key: key);

  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  String _state;
  var _subscription;

  void funs() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      //接入移动网络
      setState(() {
        _state = "移动网络";
      });
      print('移动网络');
    } else if (connectivityResult == ConnectivityResult.wifi) {
      //接入wifi网络
      setState(() {
        _state = "Wifi 网络";
      });
      print('Wifi');
    } else {
      setState(() {
        _state = "没有网络";
      });
      print('Wifi');
    }
  }

  @override
  initState() {
    super.initState();
    funs();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if (result == ConnectivityResult.mobile) {
        setState(() {
          _state = "当前网络状态：手机网络";
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          _state = "当前网络状态：Wifi 网络";
        });
      } else {
        setState(() {
          _state = "当前网络状态：没有网络";
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();

    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("检测网络变化"),
      ),
      body: Text("${_state}"),
    );
  }
}
