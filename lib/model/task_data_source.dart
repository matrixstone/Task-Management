import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/task.dart';

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> appointments) {
    this.appointments = appointments;
  }

  Task getTask(int index) {
    return appointments![index] as Task;
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
