abstract class BudgetEvent {}

class BudgetTextChangedEvent extends BudgetEvent{
  final String budgetValue;
  BudgetTextChangedEvent(this.budgetValue);
}


class BudgetDoneEvent extends BudgetEvent {
  final String budgetValue;
  BudgetDoneEvent(this.budgetValue);
}

class BudgetBackEvent extends BudgetEvent {}
