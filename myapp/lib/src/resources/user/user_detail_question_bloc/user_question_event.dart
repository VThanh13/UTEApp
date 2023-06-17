import 'package:flutter/cupertino.dart';

@immutable
abstract class UserQuestionEvent{}

class UserQuestionInitialEvent extends UserQuestionEvent{}

class UserClickSendQuestionEvent extends UserQuestionEvent{}

