class UserModel{
  String? id;
  String? name;
  String? email;
  String? image;
  String? password;
  String? phone;
  String? group;
  String? status;

  UserModel({this.id, this.name, this.email, this.image, this.password, this.phone, this.group, this.status});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    password = json['password'];
    phone = json['phone'];
    group = json['group'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['password'] = password;
    data['phone'] = phone;
    data['group'] = group;
    data['status'] = status;
    return data;
  }

  @override
  int get hashCode => Object.hash(id, name, email, image, password, phone, group, status);

  @override
  bool operator ==(Object other) {
    return other.hashCode ==  hashCode;
  }
}