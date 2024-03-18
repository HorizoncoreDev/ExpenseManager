import 'package:expense_manager/statistics/search/bloc/search_event.dart';
import 'package:expense_manager/statistics/search/bloc/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState> {

  late BuildContext context;

  SearchBloc() : super(SearchInitial());

}
