import '../value_objects/email.dart';

class Comment {
  int postId;
  int id;
  String name;
  Email email;
  String body;

  Comment({this.postId, this.id, this.name, this.email, this.body});

  Comment.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    id = json['id'];
    name = json['name'];
    email = Email(json['email']);
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email.email;
    data['body'] = this.body;
    return data;
  }
}
