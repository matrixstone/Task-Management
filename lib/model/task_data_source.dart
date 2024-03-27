import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/task.dart';

class TaskDataSource extends CalendarDataSource<Task> {
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
  Object? getId(int index) {
    return appointments![index].id;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  Color getColor(int index) {
    return appointments![index].backgroundColor;
  }

  @override
  Task? convertAppointmentToObject(Task? customData, Appointment appointment) {
    // TODO: implement convertAppointmentToObject
    return Task(
      projectId: 1,
      description: '',
      fromDate: appointment.startTime,
      toDate: appointment.endTime,
      backgroundColor: appointment.color,
      title: appointment.subject,
      isAllDay: appointment.isAllDay,
      id: appointment.id as int,
    );
  }
}
