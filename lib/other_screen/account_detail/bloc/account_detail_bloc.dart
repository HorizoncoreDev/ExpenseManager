import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'account_detail_event.dart';
import 'account_detail_state.dart';


class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {

  late BuildContext context;

  AccountDetailBloc() : super(AccountDetailInitial());


}
