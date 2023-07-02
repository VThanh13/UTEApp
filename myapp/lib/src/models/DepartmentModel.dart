class DepartmentModel{
  String? id;
  String? name;
  List<String>? category;

  DepartmentModel({this.id, this.name, this.category});

  DepartmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    return data;
  }

  // factory DepartmentModel.fromMap(Map<String, dynamic> json){
  //   return DepartmentModel(
  //       json['id'],
  //       json['name'],
  //       json['category'],
  //   );
  // }

}