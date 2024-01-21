import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/event.dart';
import 'package:task_management/pages/event_edit_page.dart';
import '../model/event_data_source.dart';
import '../provider/event_provider.dart';
// import 'package:provider/provider.dart';

final eventProvider = Provider<EventProvider>(
  (ref) => EventProvider(),
);

final eventDataProvider = FutureProvider<List<Event>>((ref) {
  return ref.read(eventProvider).getAllEvents();
});

class Calendar extends ConsumerWidget {
  final String view;
  const Calendar({super.key, required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final events = FutureProvider.of<EventProvider>(context).getAllEvents();
    // final eventsProvider = FutureProvider<List<Event>>(
    //   create: (context) => EventProvider().getAllEvents(),
    //   initialData: List<Event>.empty(),
    // );
    // final events = Provider.of<List<Event>>(context);
    final events = ref.watch(eventDataProvider);
    CalendarView calendarView = CalendarView.day;
    if (view == 'week') {
      calendarView = CalendarView.week;
    }

    // final config = ref.watch(fetchConfigurationProvider);
    return SfCalendar(
      key: ValueKey(calendarView),
      view: calendarView,
      // dataSource: EventDataSource(Provider<List<Event>>(child: events)),
      dataSource: events.when(
        data: (events) => EventDataSource(events),
        loading: () => EventDataSource(List<Event>.empty()),
        error: (error, stackTrace) => EventDataSource(List<Event>.empty()),
      ),
      // EventDataSource(events),
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
            builder: (context) => EventEditPage(event: event),
          ),
        );
      },
    );
    // return Consumer<List<Event>>(
    //   builder: (context, List<Event> events, child) {
    //     print('Current events: $events');
    //     return SfCalendar(
    //       key: ValueKey(calendarView),
    //       view: calendarView,
    //       // dataSource: EventDataSource(Provider<List<Event>>(child: events)),
    //       dataSource: EventDataSource(events),
    //       // dataSource: EventDataSource(ref.watch(eventsProvider)),
    //       // ref.watch(events)),
    //       showNavigationArrow: true,
    //       allowDragAndDrop: true,
    //       allowAppointmentResize: true,
    //       onAppointmentResizeEnd: resizeEnd,
    //       onTap: (calendarTapDetails) {
    //         if (calendarTapDetails == null) return;
    //         final event = calendarTapDetails.appointments!.first;
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) => EventEditPage(event: event),
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }

  // @riverpod
  // Future<List<Event>> fetchEvent(FetchEventRef ref) async {
  //   final content = EventProvider.getAllEvents();

  //   return content;
  // }

  // TODO: Update event after resizing
  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    dynamic appointment = appointmentResizeEndDetails.appointment;
    DateTime? startTime = appointmentResizeEndDetails.startTime;
    DateTime? endTime = appointmentResizeEndDetails.endTime;
    CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
  }
}
