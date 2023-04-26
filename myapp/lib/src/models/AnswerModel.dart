class AnswerModel{
  String id;
  String room_id;
  String content;
  String time;
  String employee_id;

  AnswerModel(
      this.id, this.room_id, this.content, this.time, this.employee_id);

  factory AnswerModel.fromMap(Map<String, dynamic> json){
    return AnswerModel(
        json['id'],
        json['room_id'],
        json['content'],
        json['time'],
        json['employee_id'],
    );
  }

}