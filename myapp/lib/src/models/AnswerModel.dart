class AnswerModel{
  String? id;
  String? room_id;
  String? content;
  String? time;
  String? employee_id;
  String? file;

  AnswerModel({this.id, this.room_id, this.content, this.time, this.employee_id, this.file});

  AnswerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    room_id = json['room_id'];
    content = json['content'];
    time = json['time'];
    employee_id = json['employee_id'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['room_id'] = room_id;
    data['content'] = content;
    data['time'] = time;
    data['employee_id'] = employee_id;
    data['file'] = file;
    return data;
  }
  // factory AnswerModel.fromMap(Map<String, dynamic> json){
  //   return AnswerModel(
  //       json['id'],
  //       json['room_id'],
  //       json['content'],
  //       json['time'],
  //       json['employee_id'],
  //   );
  // }

}