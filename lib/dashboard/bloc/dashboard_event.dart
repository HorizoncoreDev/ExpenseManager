

abstract class DashboardEvent {}

class TabChange extends DashboardEvent {
  final int tabIndex;

  TabChange({required this.tabIndex});
}

class BottomIndexChangeEvent extends DashboardEvent {
  final int currentBottomIndex;

  BottomIndexChangeEvent({required this.currentBottomIndex});
}
