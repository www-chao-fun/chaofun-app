class forumDB {
  int id;
  int followers;
  int posts;
  int tag;
  String name;
  String desc;
  String imageName;
  var joined;

  forumDB(
      {this.id,
      this.followers,
      this.posts,
      this.tag,
      this.name,
      this.desc,
      this.imageName,
      this.joined});

  forumDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    followers = json['followers'];
    posts = json['posts'];
    tag = json['tag'];
    name = json['name'];
    desc = json['desc'];
    imageName = json['imageName'];
    joined = json['joined'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['followers'] = followers;
    map['posts'] = posts;
    map['tag'] = tag;
    map['name'] = name;
    map['followers'] = followers;
    map['desc'] = desc;
    map['imageName'] = imageName;
    map['joined'] = joined;
    return map;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['followers'] = this.followers;
    data['posts'] = this.posts;
    data['tag'] = this.tag;
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['imageName'] = this.imageName;
    data['joined'] = this.joined;
    return data;
  }
}
