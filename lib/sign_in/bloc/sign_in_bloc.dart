import 'dart:async';

import 'package:expense_manager/sign_in/bloc/sign_in_event.dart';
import 'package:expense_manager/sign_in/bloc/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../budget/budget_screen.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  late BuildContext context;

  SignInBloc() : super(SignInInitial()) {
    on<SignInSkipEvent>(signInSkipEvent);
  }

  Future<void> signInSkipEvent(
      SignInSkipEvent event, Emitter<SignInState> emit) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BudgetScreen()),
    );
  }
}
