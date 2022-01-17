import 'package:flutter/material.dart';

// ChangeNotifier通知
// 切换底部导航栏
class CurrentIndexProvide with ChangeNotifier {
  // int currentIndex = 0;
  // changeIndex(int newIndex) {
  //   print('点击了第' + newIndex.toString() + '个');
  //   currentIndex = newIndex;
  //   // notifyListeners(); //通知监听者刷新页面
  // }

  int _currentIndex = 0;
  PageController pageController;

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    _currentIndex = value;
    // pageController.jumpToPage(this._currentIndex);
    print('进入切换');
    print(value);
    notifyListeners();
  }

  void setIndex(index) {
    _currentIndex = index;
    notifyListeners();
  }

  IndexProvider() {
    pageController = PageController(initialPage: _currentIndex);
  }

  //使用ChangeNotifierProvider会在销毁时调用dispose()方法释放资源
  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }
}
