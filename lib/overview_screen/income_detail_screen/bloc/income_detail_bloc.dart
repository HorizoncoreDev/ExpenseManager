import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'income_detail_event.dart';
import 'income_detail_state.dart';

class IncomeDetailBloc extends Bloc<IncomeDetailEvent, IncomeDetailState> {

  late BuildContext context;

  IncomeDetailBloc() : super(IncomeDetailInitial());


}