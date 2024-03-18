
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'other_event.dart';
import 'other_state.dart';


class OtherBloc extends Bloc<OtherEvent, OtherState> {

  late BuildContext context;

  OtherBloc() : super(OtherInitial());


}
