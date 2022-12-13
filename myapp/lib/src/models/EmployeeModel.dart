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
  String status;

  EmployeeModel(this.id, this.name, this.email, this.image, this.password,
      this.phone, this.department, this.category, this.roles, this.status);

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
        json['status'],
    );
  }

  @override
  String toString() {
    return 'EmployeeModel{id: $id, name: $name, email: $email, image: $image, password: $password, phone: $phone, department: $department, category: $category, roles: $roles, status: $status}';
  }
}