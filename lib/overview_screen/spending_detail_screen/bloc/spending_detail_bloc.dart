import 'package:expense_manager/overview_screen/spending_detail_screen/bloc/spending_detail_event.dart';
import 'package:expense_manager/overview_screen/spending_detail_screen/bloc/spending_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpendingDetailBloc extends Bloc<SpendingDetailEvent, SpendingDetailState> {

  late BuildContext context;

  SpendingDetailBloc() : super(SpendingDetailInitial());


}