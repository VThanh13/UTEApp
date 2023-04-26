class UserModel{
  String id;
  String name;
  String email;
  String image;
  String password;
  String phone;
  String group;
  String status;

  UserModel(
      this.id, this.name, this.email, this.image, this.password, this.phone, this.group, this.status);

  factory UserModel.fromMap(Map<String, dynamic> json){
    return UserModel(
        json['id'],
        json['name'],
        json['email'],
        json['image'],
        json['password'],
        json['phone'],
        json['group'],
        json['status'],
    );
  }

}