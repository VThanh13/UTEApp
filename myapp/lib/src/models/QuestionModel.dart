class QuestionModel{
  String? id;
  String? room_id;
  String? content;
  String? time;
  String? file;

  QuestionModel({this.id, this.room_id, this.content, this.time, this.file});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    room_id = json['room_id'];
    content = json['content'];
    time = json['time'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['room_id'] = this.room_id;
    data['content'] = this.content;
    data['time'] = this.time;
    data['file'] = this.file;
    return data;
  }

  // factory QuestionModel.fromMap(Map<String, dynamic> json){
  //   return QuestionModel(
  //     json['id'],
  //     json['room_id'],
  //     json['content'],
  //     json['time'],
  //     json['file'],
  //   );
  // }
}