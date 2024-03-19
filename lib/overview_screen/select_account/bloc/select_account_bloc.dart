import 'package:expense_manager/overview_screen/select_account/bloc/select_account_event.dart';
import 'package:expense_manager/overview_screen/select_account/bloc/select_account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectAccountBloc extends Bloc<SelectAccountEvent, SelectAccountState> {
  late BuildContext context;

  SelectAccountBloc() : super(SelectAccountInitial());
}
