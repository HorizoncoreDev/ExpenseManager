import 'package:flutter/material.dart';

extension NumExtension on num {
  Widget get heightBox => SizedBox(
        height: toDouble(),
      );

  Widget get widthBox => SizedBox(
        width: toDouble(),
      );
/*void addCsvDataToDatabase() {
    for (int i = 1; i < data.length; i++) {
      // Start from index 1 to skip the header row
      ToDoModel todoModel = ToDoModel(
        id: data[i][0].toString(),
        todoText: data[i][1].toString(),
        time: data[i][3].toString(),
        date: data[i][4].toString(),
        priority: Priority.values[int.tryParse(data[i][5]) ?? 0],
      );
      // Add the ToDoModel to the database
      DatabaseHelper.addTask(todoModel);
    }
  }*/
}
