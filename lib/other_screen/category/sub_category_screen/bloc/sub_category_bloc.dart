import 'package:expense_manager/other_screen/category/sub_category_screen/bloc/sub_category_state.dart';
import 'package:expense_manager/other_screen/category/sub_category_screen/bloc/sub_catgory_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {

  late BuildContext context;

  SubCategoryBloc() : super(SubCategoryInitial());


}