import 'package:expense_manager/overview_screen/spending_detail_screen/bloc/spending_detail_event.dart';
import 'package:expense_manager/overview_screen/spending_detail_screen/bloc/spending_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpendingDetailBloc
    extends Bloc<SpendingDetailEvent, SpendingDetailState> {
  late BuildContext context;


  SpendingDetailBloc() : super(SpendingDetailInitial(
    // ListView.builder(
    //   itemCount: data.length > 1 ? data.length - 1 : 0,
    //   // Adjusted for skipping the header row
    //   itemBuilder: (context, index) {
    //     if (index >= data.length - 1) {
    //       return const SizedBox(); // Return an empty SizedBox if the index is out of range
    //     }
    //     // Create a ToDoModel object from CSV data
    //     ToDoModel todoModel = ToDoModel(
    //       id: data[index + 1][0].toString(),
    //       // Adjusted index and added 1 to skip the header row
    //       todoText: data[index + 1][1].toString(),
    //       // Adjusted index and added 1 to skip the header row
    //       time: data[index + 1][3].toString(),
    //       // Adjusted index and added 1 to skip the header row
    //       date: data[index + 1][4].toString(),
    //       // Adjusted index and added 1 to skip the header row
    //       priority: Priority.values[int.tryParse(
    //           data[index + 1][5]) ??
    //           0], // Adjusted index and added 1 to skip the header row
    //     );
    //
    //     return Dismissible(
    //       key: Key(todoModel.id!),
    //       // Use the ID as the key for Dismissible
    //       direction: DismissDirection.startToEnd,
    //       onDismissed: (direction) {
    //         // Remove the item from the database and reload the tasks
    //         deleteToDoItem(todoModel.id!);
    //       },
    //       background: Container(
    //         color: Colors.red,
    //         // Background color when swiping
    //         alignment: Alignment.centerRight,
    //         padding: const EdgeInsets.symmetric(horizontal: 20),
    //         child: const Icon(
    //           Icons.delete,
    //           color: Colors.white,
    //         ),
    //       ),
    //       child: Card(
    //         margin: const EdgeInsets.symmetric(vertical: 4),
    //         child: ToDoItem(
    //           toDoModel: todoModel,
    //           onToDoChanged: handleToDoChange,
    //           onDeleteItem: deleteToDoItem,
    //           onPriorityChanged: handlePriorityChange,
    //           isDarkMode: isDarkMode,
    //           onMultipleDelete: onMultipleDelete,
    //           isTaskSelected: isTaskSelected,
    //         ),
    //       ),
    //     );
    //   },
    // ),
  ));
}
