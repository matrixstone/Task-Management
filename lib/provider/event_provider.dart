import 'package:flutter/cupertino.dart';

import '../model/event.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void editEvent(Event event, Event newEvent) {
    final index = _events.indexOf(event);

    _events[index] = newEvent;
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }
}
