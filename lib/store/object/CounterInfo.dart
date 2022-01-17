class CounterInfo extends Object {
  int count;
  TotalInfo totalInfo;

  CounterInfo({this.count, this.totalInfo});

  CounterInfo.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    totalInfo = TotalInfo.fromJson(json['totalInfo']);
  }
}

class TotalInfo extends Object {
  int total;

  TotalInfo({this.total});

  TotalInfo.fromJson(Map<String, dynamic> json) {
    print('----------------- $json');
    total = json['total'];
  }
}
