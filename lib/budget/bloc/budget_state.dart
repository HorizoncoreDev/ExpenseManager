abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetDoneState extends BudgetState {}

class BudgetBackState extends BudgetState {}

class BudgetDoneErrorState extends BudgetState{
  BudgetDoneErrorState();
}