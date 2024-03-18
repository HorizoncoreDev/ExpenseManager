
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_spending_event.dart';
import 'add_spending_state.dart';


class AddSpendingBloc extends Bloc<AddSpendingEvent, AddSpendingState> {

  late BuildContext context;

  AddSpendingBloc() : super(AddSpendingInitial());


}
