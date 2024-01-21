import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/main.dart';
import 'package:task_management/model/event.dart';
import 'package:task_management/pages/event_edit_page.dart';
import '../model/event_data_source.dart';
import '../provider/event_provider.dart';
// import 'package:provider/provider.dart';

class Calendar extends StatelessWidget {
  final String view;
  EventProvider eventProvider;
  Calendar({super.key, required this.view, required this.eventProvider});

  @override
  Widget build(BuildContext context) {
    CalendarView calendarView = CalendarView.day;
    if (view == 'week') {
      calendarView = CalendarView.week;
    }

    // final config = ref.watch(fetchConfigurationProvider);
    return ListenableBuilder(
        listenable: eventProvider,
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<List<Event>>(
              future: eventProvider.getAllEvents(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
                List<Event> events = List.empty();
                if (snapshot.hasData) {
                  events = snapshot.data!;
                }

                print('Testing load events: $events');

                return SfCalendar(
                  key: ValueKey(calendarView),
                  view: calendarView,
                  dataSource: EventDataSource(events),
                  // dataSource: EventDataSource(ref.watch(eventsProvider)),
                  // ref.watch(events)),
                  showNavigationArrow: true,
                  allowDragAndDrop: true,
                  allowAppointmentResize: true,
                  onAppointmentResizeEnd: resizeEnd,
                  onTap: (calendarTapDetails) {
                    if (calendarTapDetails == null) return;
                    final event = calendarTapDetails.appointments!.first;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventEditPage(
                            event: event, eventProvider: eventProvider),
                      ),
                    );
                  },
                );
              });
        });
  }

  // TODO: Update event after resizing
  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    dynamic appointment = appointmentResizeEndDetails.appointment;
    DateTime? startTime = appointmentResizeEndDetails.startTime;
    DateTime? endTime = appointmentResizeEndDetails.endTime;
    CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
  }
}
