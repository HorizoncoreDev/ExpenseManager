import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../sign_in/sign_in_screen.dart';
import 'intro_event.dart';
import 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  late BuildContext context;

  IntroBloc() : super(IntroInitial()) {
    on<IntroStartEvent>(introStartEvent);
  }

  Future<void> introStartEvent(
      IntroStartEvent event, Emitter<IntroState> emit) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),(Route<dynamic> route) => false);

  }
}
