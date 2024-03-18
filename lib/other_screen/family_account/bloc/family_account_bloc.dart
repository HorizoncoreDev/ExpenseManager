import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'family_account_event.dart';
import 'family_account_state.dart';


class FamilyAccountBloc extends Bloc<FamilyAccountEvent, FamilyAccountState> {

  late BuildContext context;

  FamilyAccountBloc() : super(FamilyAccountInitial());


}
