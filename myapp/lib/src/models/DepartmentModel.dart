class DepartmentModel{
  String id;
  String name;
  String categoryId;

  DepartmentModel(
      this.id, this.name, this.categoryId);

  factory DepartmentModel.fromMap(Map<String, dynamic> json){
    return DepartmentModel(
        json['id'],
        json['name'],
        json['categoryId'],
    );
  }

}