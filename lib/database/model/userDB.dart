class userDB {
  int userId;
  String userName;
  String icon;
  int ups;
  var followers;
  String desc;
  var phone;
  var gmtCreate;
  var gmtModified;

  userDB(
      {this.userId,
      this.userName,
      this.icon,
      this.ups,
      this.followers,
      this.desc,
      this.phone,
      this.gmtCreate,
      this.gmtModified});

  userDB.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    icon = json['icon'];
    ups = json['ups'];
    followers = json['followers'];
    desc = json['desc'];
    phone = json['phone'];
    gmtCreate = json['gmtCreate'];
    gmtModified = json['gmtModified'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['userName'] = userName;
    map['icon'] = icon;
    map['ups'] = ups;
    map['followers'] = followers;
    map['desc'] = desc;
    map['phone'] = phone;
    map['gmtCreate'] = gmtCreate;
    map['gmtModified'] = gmtModified;
    return map;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['icon'] = this.icon;
    data['ups'] = this.ups;
    data['followers'] = this.followers;
    data['desc'] = this.desc;
    data['phone'] = this.phone;
    data['gmtCreate'] = this.gmtCreate;
    data['gmtModified'] = this.gmtModified;
    return data;
  }
}
