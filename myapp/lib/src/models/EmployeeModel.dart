class EmployeeModel{
  String id;
  String name;
  String email;
  String image;
  String password;
  String phone;
  String department;
  String category;
  String roles;

  EmployeeModel(this.id, this.name, this.email, this.image, this.password,
      this.phone, this.department, this.category, this.roles);

  factory EmployeeModel.fromMap(Map<String, dynamic> json){
    return EmployeeModel(
        json['id'],
        json['name'],
        json['email'],
        json['image'],
        json['password'],
        json['phone'],
        json['department'],
        json['category'],
        json['roles'],
    );
  }

}