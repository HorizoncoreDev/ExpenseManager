import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dashboard/dashboard.dart';
import '../../utils/helper.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  late BuildContext context;

  BudgetBloc() : super(BudgetInitial()) {
    on<BudgetDoneEvent>(budgetDoneEvent);
  }

  Future<void> budgetDoneEvent(
      BudgetDoneEvent event, Emitter<BudgetState> emit) async {
    if (event.budgetValue.isEmpty) {
      Helper.showToast('Enter your budget');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashBoard()),
      );
    }
  }
}
