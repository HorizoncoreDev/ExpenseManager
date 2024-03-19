import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_account_detail_event.dart';
import 'edit_account_detail_state.dart';

class EditAccountDetailBloc
    extends Bloc<EditAccountDetailEvent, EditAccountDetailState> {
  late BuildContext context;

  EditAccountDetailBloc() : super(EditAccountDetailInitial());
}
