import 'package:expense_manager/statistics/bloc/statistics_event.dart';
import 'package:expense_manager/statistics/bloc/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  late BuildContext context;

  StatisticsBloc() : super(StatisticsInitial());




}
