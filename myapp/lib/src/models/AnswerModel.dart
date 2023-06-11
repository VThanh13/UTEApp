class AnswerModel{
  String? id;
  String? room_id;
  String? content;
  String? time;
  String? employee_id;

  AnswerModel({this.id, this.room_id, this.content, this.time, this.employee_id});

  AnswerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    room_id = json['room_id'];
    content = json['content'];
    time = json['time'];
    employee_id = json['employee_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['room_id'] = this.room_id;
    data['content'] = this.content;
    data['time'] = this.time;
    data['employee_id'] = this.employee_id;
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