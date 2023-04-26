class QuestionModel{
  String id;
  String room_id;
  String content;
  String time;
  String file;


  QuestionModel(this.id, this.room_id, this.content, this.time, this.file);

  factory QuestionModel.fromMap(Map<String, dynamic> json){
    return QuestionModel(
      json['id'],
      json['room_id'],
      json['content'],
      json['time'],
      json['file'],
    );
  }
}