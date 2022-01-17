class UserInfo extends Object {
  bool isLogin;
  String userName;
  String icon;
  String desc;
  int ups;
  int userId;

  UserInfo(
      {this.isLogin,
      this.userName,
      this.icon,
      this.desc,
      this.ups,
      this.userId});

  UserInfo.fromJson(Map<String, dynamic> json) {
    isLogin = json['isLogin'];
    userName = json['userName'];
    icon = json['icon'];
    desc = json['desc'];
    ups = json['ups'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isLogin'] = this.isLogin;
    data['userName'] = this.userName;
    data['icon'] = this.icon;
    data['desc'] = this.desc;
    data['ups'] = this.ups;
    data['userId'] = this.userId;
    return data;
  }
}
