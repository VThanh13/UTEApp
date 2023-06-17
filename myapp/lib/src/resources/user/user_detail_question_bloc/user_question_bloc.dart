import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/resources/user/user_detail_question_bloc/user_question_event.dart';
import 'package:myapp/src/resources/user/user_detail_question_bloc/user_question_state.dart';

class UserQuestionBloc extends Bloc<UserQuestionEvent, UserQuestionState>{
  UserQuestionBloc() :super(UserQuestionInitialState()){
    on<UserQuestionInitialEvent>(userQuestionInitialEvent);
    on<UserClickSendQuestionEvent>(userClickSendQuestionEvent);
  }

  FutureOr<void> userQuestionInitialEvent(UserQuestionInitialEvent event, Emitter<UserQuestionState> emit) {
  emit(UserQuestionInitialState());
  }

  FutureOr<void> userClickSendQuestionEvent(UserClickSendQuestionEvent event, Emitter<UserQuestionState> emit) {
  emit(UserClickSendQuestionState());
  }
}