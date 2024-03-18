
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'general_setting_event.dart';
import 'general_setting_state.dart';


class GeneralSettingBloc extends Bloc<GeneralSettingEvent, GeneralSettingState> {

  late BuildContext context;

  GeneralSettingBloc() : super(GeneralSettingInitial());


}
