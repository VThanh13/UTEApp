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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['image'] = this.image;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['group'] = this.group;
    data['status'] = this.status;
    return data;
  }

  // factory UserModel.fromMap(Map<String, dynamic> json){
  //   return UserModel(
  //       json['id'],
  //       json['name'],
  //       json['email'],
  //       json['image'],
  //       json['password'],
  //       json['phone'],
  //       json['group'],
  //       json['status'],
  //   );
  // }

}