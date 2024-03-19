import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_library_event.dart';
import 'my_library_state.dart';

class MyLibraryBloc extends Bloc<MyLibraryEvent, MyLibraryState> {
  late BuildContext context;

  MyLibraryBloc() : super(MyLibraryInitial());
}
