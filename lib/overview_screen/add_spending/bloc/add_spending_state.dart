import 'dart:io';

abstract class AddSpendingState {}

class AddSpendingInitial extends AddSpendingState {}

class SelectedImageState extends AddSpendingState {
  File? image1, image2, image3;
  SelectedImageState(this.image1,this.image2,this.image3);
}

