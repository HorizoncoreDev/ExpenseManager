
import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class AddSpendingEvent {
  BuildContext context;

  AddSpendingEvent({
    required this.context,
  });
}

class OnImageSelectedEvent extends AddSpendingEvent {
  File? image1, image2, image3;
  OnImageSelectedEvent({required super.context,this.image1,this.image2,this.image3});
}
