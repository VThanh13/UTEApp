class QuestionModel{
  String id;
  String title;
  String content;
  String time;
  String department;
  String category;
  String status;
  String userId;
  String information;
  String file;


  QuestionModel(this.id, this.title, this.content, this.time, this.department,
      this.category, this.status, this.userId, this.information, this.file);

  factory QuestionModel.fromMap(Map<String, dynamic> json){
    return QuestionModel(
      json['id'],
      json['title'],
      json['content'],
      json['time'],
      json['department'],
      json['category'],
      json['status'],
      json['userId'],
      json['information'],
      json['file'],
    );
  }
}