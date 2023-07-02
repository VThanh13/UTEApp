class QuestionModel{
  String? id;
  String? roomId;
  String? content;
  String? time;
  String? file;

  QuestionModel({this.id, this.roomId, this.content, this.time, this.file});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    content = json['content'];
    time = json['time'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['room_id'] = roomId;
    data['content'] = content;
    data['time'] = time;
    data['file'] = file;
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