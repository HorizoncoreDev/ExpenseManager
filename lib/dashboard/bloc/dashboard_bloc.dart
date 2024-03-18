/*

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';


class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {

  late BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentTabController controller =
  PersistentTabController(initialIndex: 0);

  DashboardBloc() : super(DashboardInitial()) {
    on<TabChange>(tabChange);
    on<BottomIndexChangeEvent>(bottomIndexChangeEvent);
  }

  Future<void> tabChange(TabChange event, Emitter<DashboardState> emit) async {
    emit(DashboardInitialState(tabIndex: event.tabIndex));
  }

  Future<void> bottomIndexChangeEvent(
      BottomIndexChangeEvent event, Emitter<DashboardState> emit) async {
    currentBottomIndex = event.currentBottomIndex;
  }
}
*/
