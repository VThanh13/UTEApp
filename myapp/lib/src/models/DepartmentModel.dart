class DepartmentModel{
  String id;
  String name;
  List<String> category;

  DepartmentModel(
      this.id, this.name, this.category);

  factory DepartmentModel.fromMap(Map<String, dynamic> json){
    return DepartmentModel(
        json['id'],
        json['name'],
        json['category'],
    );
  }

}