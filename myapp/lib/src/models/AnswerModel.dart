class AnswerModel{
  String id;
  String questionId;
  String content;
  String time;
  String userId;

  AnswerModel(
      this.id, this.questionId, this.content, this.time, this.userId);

  factory AnswerModel.fromMap(Map<String, dynamic> json){
    return AnswerModel(
        json['id'],
        json['questionId'],
        json['content'],
        json['time'],
        json['userId'],
    );
  }

}