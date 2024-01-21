import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }

  Event getEvent(int index) {
    return appointments![index] as Event;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].fromDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].toDate;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
