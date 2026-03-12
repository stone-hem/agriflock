import 'package:flutter/foundation.dart';

/// Events that can trigger a refresh across screens.
enum RefreshEvent {
  /// A batch was created → dashboard, houses, farms
  batchCreated,

  /// A daily record (feed/vaccine/medication) was saved → dashboard
  recordCreated,

  /// An expense / purchase was recorded → dashboard, expenditures
  expenseCreated,
}

/// Global event bus for cross-screen refresh signals.
///
/// Usage – fire an event after a successful save:
/// ```dart
/// RefreshBus.instance.fire(RefreshEvent.batchCreated);
/// ```
///
/// Usage – listen in a StatefulWidget:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   RefreshBus.instance.addListener(_onRefreshBus);
/// }
///
/// void _onRefreshBus() {
///   final event = RefreshBus.instance.lastEvent;
///   if (event == RefreshEvent.batchCreated) _loadData();
/// }
///
/// @override
/// void dispose() {
///   RefreshBus.instance.removeListener(_onRefreshBus);
///   super.dispose();
/// }
/// ```
class RefreshBus extends ChangeNotifier {
  RefreshBus._();
  static final RefreshBus instance = RefreshBus._();

  RefreshEvent? _lastEvent;

  /// The most recently fired event.
  RefreshEvent? get lastEvent => _lastEvent;

  /// Fire an event and notify all listeners.
  void fire(RefreshEvent event) {
    _lastEvent = event;
    notifyListeners();
  }
}
