import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/pages/calendar_widget.dart';
import 'package:task_management/pages/project_edit_page.dart';
import 'package:task_management/pages/report_page.dart';
import 'package:task_management/pages/task_edit_page.dart';
import 'package:task_management/pages/navigation_drawer_widget.dart';
import 'package:task_management/provider/data_provider.dart';
import 'package:task_management/provider/project_provider.dart';
import 'package:task_management/provider/task_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:developer';

void main() {
  databaseFactory = databaseFactoryFfiWeb;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      exit(1);
    };
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentView = 'day';
  int pageIndex = 0; // 0: day, 0: week

  _setCalendarView(String view) {
    setState(() {
      currentView = view;
    });
  }

  _setPageIndex(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    log('Testing currentView: $currentView');

    int navigationBarIndex = 0;
    if (currentView == 'week') {
      navigationBarIndex = 1;
    }

    final TaskProvider taskProvider = TaskProvider();
    final ProjectProvider projectProvider = ProjectProvider();
    final DataProvider dataProvider = DataProvider();

    List<Widget> allPages = [
      // The first and 2nd pages are Calendar pages.
      // First page is Day, 2nd page is Week.
      ListenableBuilder(
          listenable: projectProvider,
          builder: (BuildContext context, Widget? child) {
            return FutureBuilder<List<Project>>(
                future: projectProvider.getAllProjects(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Project>> snapshot) {
                  List<Project> projects = List.empty();
                  if (snapshot.hasData) {
                    projects = snapshot.data!;
                  }
                  return Calendar(
                      view: currentView,
                      taskProvider: taskProvider,
                      projects: projects);
                });
          }),
      // 3rd page is project management.
      ListenableBuilder(
          listenable: projectProvider,
          builder: (BuildContext context, Widget? child) {
            return FutureBuilder<List<Project>>(
                future: projectProvider.getAllProjects(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Project>> snapshot) {
                  List<Project> projects = List.empty();
                  if (snapshot.hasData) {
                    projects = snapshot.data!;
                  }
                  log('Testing projects after future: $projects');

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                          leading: const Icon(Icons.list),
                          onTap: () => _navigateProjectEditPage(
                              context, projectProvider, projects[index]),
                          title: Text("Project: ${projects[index].title}"));
                    },
                  );
                });
          }),
      ListenableBuilder(
          listenable: taskProvider,
          builder: (BuildContext context, Widget? child) {
            return ListenableBuilder(
                listenable: projectProvider,
                builder: (BuildContext context, Widget? child) {
                  return FutureBuilder<Map<Project, Map<DateTime, double>>>(
                      future: dataProvider.getProjectsToTime(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<Project, Map<DateTime, double>>>
                              snapshot) {
                        Map<Project, Map<DateTime, double>> projectsToTime = {};
                        if (snapshot.hasData) {
                          projectsToTime = snapshot.data!;
                        }
                        log('Testing projectsToTime after future: $projectsToTime');

                        return ReportPage(projectsToTime: projectsToTime);
                      });
                });
          }),
    ];

    List<Widget> allFloatinngActions = [
      ListenableBuilder(
          listenable: projectProvider,
          builder: (BuildContext context, Widget? child) {
            return FutureBuilder<List<Project>>(
                future: projectProvider.getAllProjects(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Project>> snapshot) {
                  List<Project> projects = List.empty();
                  if (snapshot.hasData) {
                    projects = snapshot.data!;
                  }
                  return FloatingActionButton(
                    onPressed: () =>
                        _navigateEditPage(context, taskProvider, projects),
                    tooltip: 'Add Task',
                    child: const Icon(Icons.add),
                  );
                });
          }),
      FloatingActionButton(
        onPressed: () => _navigateProjectEditPage(context, projectProvider),
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    ];
    if (pageIndex < 2) {
      return Scaffold(
        drawer: NavigationDrawerWidget(
            setCalendarView: _setCalendarView,
            setPageIndex: _setPageIndex,
            selectedIndex: navigationBarIndex),
        appBar: AppBar(
          title: const Text('Task Management'),
          centerTitle: true,
        ),
        body: allPages[pageIndex],
        floatingActionButton: allFloatinngActions[pageIndex],
      );
    } else {
      return Scaffold(
        drawer: NavigationDrawerWidget(
            setCalendarView: _setCalendarView,
            setPageIndex: _setPageIndex,
            selectedIndex: navigationBarIndex),
        appBar: AppBar(
          title: const Text('Task Management'),
          centerTitle: true,
        ),
        body: allPages[pageIndex],
      );
    }
  }

  Future<void> _navigateEditPage(BuildContext context,
      TaskProvider taskProvider, List<Project> projects) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TaskEditPage(taskProvider: taskProvider, projects: projects),
      ),
    );
  }

  Future<void> _navigateProjectEditPage(
      BuildContext context, ProjectProvider projectProvider,
      [Project? project]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProjectEditPage(project: project, projectProvider: projectProvider),
      ),
    );
  }

  // Future<void> _navigateReportPage(BuildContext context) async {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ReportPage(),
  //     ),
  //   );
  // }
}
