

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}


class DashboardInitialState extends DashboardState {
  final int tabIndex;

  DashboardInitialState({required this.tabIndex});
}