import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/model/task.dart';
import 'package:task_management/pages/task_edit_page.dart';
import '../model/task_data_source.dart';
import '../provider/task_provider.dart';
import 'dart:developer';
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
                  allowAppointmentResize: true,
                  onAppointmentResizeEnd: resizeEnd,
                  allowDragAndDrop: true,
                  backgroundColor: Colors.white,
                  onDragEnd: dragEnd,
                  showDatePickerButton: true,
                  showTodayButton: true,
                  allowViewNavigation: true,
                  allowedViews: const <CalendarView>[
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.month,
                    CalendarView.schedule
                  ],
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
                    if (projects.isEmpty) {
                      // We have to have a project defined before creating tasks.
                      // If there is no project, show alert page.
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //       builder: (context) => const AlertDialog(
                      //           title: Text('Create projects firstly.'))),
                      // );
                      showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text('Create projects firstly.')));
                    } else {
                      // Trigger task edit or create page if projects is not empty.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskEditPage(
                              task: task,
                              taskProvider: taskProvider,
                              projects: projects),
                        ),
                      );
                    }
                  },
                );
              });
        });
  }

  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    Task updatedTask = appointmentResizeEndDetails.appointment as Task;
    taskProvider.updateTaskTime(
        updatedTask.id, updatedTask.fromDate, updatedTask.toDate);
  }

  void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
    Task updatedTask = appointmentDragEndDetails.appointment as Task;
    taskProvider.updateTaskTime(
        updatedTask.id, updatedTask.fromDate, updatedTask.toDate);
  }
}
