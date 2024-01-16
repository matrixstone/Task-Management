import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/event.dart';
import 'package:task_management/pages/event_edit_page.dart';

import '../model/event_data_source.dart';
import '../provider/event_provider.dart';

class Calendar extends StatelessWidget {
  final String view;
  const Calendar({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    CalendarView calendarView = CalendarView.day;
    if (view == 'week') {
      calendarView = CalendarView.week;
    }
    return SfCalendar(
      key: ValueKey(calendarView),
      view: calendarView,
      dataSource: EventDataSource(events),
      showNavigationArrow: true,
      allowDragAndDrop: true,
      allowAppointmentResize: true,
      onAppointmentResizeEnd: resizeEnd,
      onTap: (calendarTapDetails) {
        if (calendarTapDetails == null) return;
        final event = calendarTapDetails.appointments!.first;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventEditPage(event: event),
          ),
        );
      },
    );
  }

  // TODO: Update event after resizing
  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    dynamic appointment = appointmentResizeEndDetails.appointment;
    DateTime? startTime = appointmentResizeEndDetails.startTime;
    DateTime? endTime = appointmentResizeEndDetails.endTime;
    CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
  }
}
