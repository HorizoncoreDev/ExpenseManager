import 'package:expense_manager/plan/bloc/plan_event.dart';
import 'package:expense_manager/plan/bloc/plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  late BuildContext context;

  PlanBloc() : super(PlanInitial());
}
