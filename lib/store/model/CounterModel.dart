import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../object/CounterInfo.dart';
export '../object/CounterInfo.dart';

class Counter extends CounterInfo with ChangeNotifier {
  CounterInfo _counterInfo =
      CounterInfo(count: 0, totalInfo: TotalInfo(total: 2));

  int get count => _counterInfo.count;
  TotalInfo get totalInfo => _counterInfo.totalInfo;

  void increment() {
    _counterInfo.count++;
    notifyListeners();
  }

  void decrement() {
    _counterInfo.count--;
    notifyListeners();
  }
}
