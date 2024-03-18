abstract class OverviewEvent {}

class ChangeTabEvent extends OverviewEvent {
  final int tabIndex;

  ChangeTabEvent(this.tabIndex);
}

