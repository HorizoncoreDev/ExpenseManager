import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_category_event.dart';
import 'add_category_state.dart';


class AddCategoryBloc extends Bloc<AddCategoryEvent, AddCategoryState> {

  late BuildContext context;

  AddCategoryBloc() : super(AddCategoryInitial());


}
