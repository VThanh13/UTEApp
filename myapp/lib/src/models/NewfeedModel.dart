class NewfeedModel{
  String? id;
  String? employeeId;
  String? content;
  String? time;
  String? file;

  NewfeedModel({this.id, this.employeeId, this.content, this.time, this.file});

  NewfeedModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employeeId'];
    content = json['content'];
    time = json['time'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employeeId'] = employeeId;
    data['content'] = content;
    data['time'] = time;
    data['file'] = file;
    return data;
  }

  // factory NewfeedModel.fromMap(Map<String, dynamic> json){
  //   return NewfeedModel(json['id'], json['employeeId'], json['content'], json['time'], json['file']);
  // }

}