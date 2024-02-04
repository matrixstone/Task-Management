import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/model/task.dart';
import 'package:task_management/pages/task_edit_page.dart';
import '../model/task_data_source.dart';
import '../provider/task_provider.dart';
// import 'package:provider/provider.dart';

class Calendar extends StatelessWidget {
  final String view;
  TaskProvider taskProvider;
  List<Project> projects;
  Calendar(
      {super.key,
      required this.view,
      required this.taskProvider,
      required this.projects});

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

                return SfCalendar(
                  key: ValueKey(calendarView),
                  view: calendarView,
                  dataSource: TaskDataSource(tasks),
                  showNavigationArrow: true,
                  allowDragAndDrop: true,
                  allowAppointmentResize: true,
                  // onAppointmentResizeEnd: resizeEnd,
                  onTap: (calendarTapDetails) {
                    Task task;
                    if (calendarTapDetails.appointments == null ||
                        calendarTapDetails.appointments!.isEmpty) {
                      task = Task(
                        projectId: 1, // default starting from the first project
                        title: '',
                        description: '',
                        fromDate: calendarTapDetails.date!,
                        toDate: calendarTapDetails.date!
                            .add(const Duration(hours: 1)),
                      );
                    } else {
                      task = calendarTapDetails.appointments!.first;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskEditPage(
                            task: task,
                            taskProvider: taskProvider,
                            projects: projects),
                      ),
                    );
                  },
                );
              });
        });
  }

  // TODO: Update event after resizing
  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    // dynamic appointment = appointmentResizeEndDetails.appointment;
    // DateTime? startTime = appointmentResizeEndDetails.startTime;
    // DateTime? endTime = appointmentResizeEndDetails.endTime;
    // CalendarResource? resourceDetails = appointmentResizeEndDetails.resource;
  }
}
