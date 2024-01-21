import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/main.dart';
import 'package:task_management/model/task.dart';
import 'package:task_management/pages/task_edit_page.dart';
import '../model/task_data_source.dart';
import '../provider/task_provider.dart';
// import 'package:provider/provider.dart';

class Calendar extends StatelessWidget {
  final String view;
  TaskProvider taskProvider;
  Calendar({super.key, required this.view, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    CalendarView calendarView = CalendarView.day;
    if (view == 'week') {
      calendarView = CalendarView.week;
    }

    // final config = ref.watch(fetchConfigurationProvider);
    return ListenableBuilder(
        listenable: taskProvider,
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<List<Task>>(
              future: taskProvider.getAllTasks(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                List<Task> tasks = List.empty();
                if (snapshot.hasData) {
                  tasks = snapshot.data!;
                }

                print('Testing load tasks: $tasks');

                return SfCalendar(
                  key: ValueKey(calendarView),
                  view: calendarView,
                  dataSource: TaskDataSource(tasks),
                  showNavigationArrow: true,
                  allowDragAndDrop: true,
                  allowAppointmentResize: true,
                  onAppointmentResizeEnd: resizeEnd,
                  onTap: (calendarTapDetails) {
                    if (calendarTapDetails == null) return;
                    final task = calendarTapDetails.appointments!.first;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskEditPage(
                            task: task, taskProvider: taskProvider),
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
