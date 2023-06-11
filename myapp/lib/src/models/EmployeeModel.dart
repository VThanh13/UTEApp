class EmployeeModel{
  late String? id;
  late String? name;
  late String? email;
  late String? image;
  late String? password;
  late String? phone;
  late String? department;
  late List<String>? category;
  late String? roles;
  late String? status;

  EmployeeModel({this.id, this.name, this.email, this.image, this.password, this.phone, this.department, this.category, this.roles, this.status});

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    password = json['password'];
    phone = json['phone'];
    department = json['department'];
    category = json['category'];
    roles = json['roles'];
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
    data['department'] = this.department;
    data['category'] = this.category;
    data['roles'] = this.roles;
    data['status'] = this.status;
    return data;
  }

  // factory EmployeeModel.fromMap(Map<String, dynamic> json){
  //   return EmployeeModel(
  //       json['id'],
  //       json['name'],
  //       json['email'],
  //       json['image'],
  //       json['password'],
  //       json['phone'],
  //       json['department'],
  //       json['category'],
  //       json['roles'],
  //       json['status'],
  //   );
  // }

  @override
  String toString() {
    return 'EmployeeModel{id: $id, name: $name, email: $email, image: $image, password: $password, phone: $phone, department: $department, category: $category, roles: $roles, status: $status}';
  }
}