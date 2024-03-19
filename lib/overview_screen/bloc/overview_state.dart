abstract class OverviewState {}

class TabBarInitialState extends OverviewState {
  final int initialTabIndex;

  TabBarInitialState(this.initialTabIndex);
}

class TabChangedState extends OverviewState {
  final int currentTabIndex;

  TabChangedState(this.currentTabIndex);
}

class OverviewInitial extends OverviewState {}

class OverviewStartState extends OverviewState {}

class OverviewSearchClickState extends OverviewState {}

class OverviewOtherClickState extends OverviewState {}
