class UserModel{
  String id;
  String name;
  String email;
  String image;
  String password;
  String phone;

  UserModel(
      this.id, this.name, this.email, this.image, this.password, this.phone);

  factory UserModel.fromMap(Map<String, dynamic> json){
    return UserModel(
        json['id'],
        json['name'],
        json['email'],
        json['image'],
        json['password'],
        json['phone'],
    );
  }

}