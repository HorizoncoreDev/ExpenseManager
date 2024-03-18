import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'overview_event.dart';
import 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {

  late BuildContext context;

  OverviewBloc() : super(OverviewInitial()) {

    /*on<ChangeTabEvent>(changeTabEvent);*/
  }

  Future<void> changeTabEvent(ChangeTabEvent event, Emitter<OverviewState> emit) async {
    emit(TabChangedState(event.tabIndex));
  }
}