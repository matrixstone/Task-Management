import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite show databaseFactory;
import 'package:task_management/pages/project_card.dart';

void main() {
  if (!kIsWeb) {
    sqfliteFfiInit();
  }
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    databaseFactory = sqflite.databaseFactory;
  }

  // databaseFactory = databaseFactoryFfiWeb;

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
        // primarySwatch: Colors.red,
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        bottomAppBarTheme: const BottomAppBarTheme(
            // color: Color.fromRGBO(241, 241, 241, 0.004)),
            color: Colors.white),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
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

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (_, index) {
                      return ProjectCard(
                          project: projects[index],
                          projectProvider: projectProvider);
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
        // drawer: NavigationDrawerWidget(
        //     setCalendarView: _setCalendarView,
        //     setPageIndex: _setPageIndex,
        //     selectedIndex: navigationBarIndex),
        appBar: AppBar(
          title: const Text('Task Management'),
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        body: allPages[pageIndex],
        floatingActionButton: allFloatinngActions[pageIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _managementBottomAppBar(),
      );
    } else {
      return Scaffold(
        // drawer: NavigationDrawerWidget(
        //     setCalendarView: _setCalendarView,
        //     setPageIndex: _setPageIndex,
        //     selectedIndex: navigationBarIndex),
        appBar: AppBar(
          title: const Text('Task Management'),
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(child: allPages[pageIndex]),
        bottomNavigationBar: _managementBottomAppBar(),
      );
    }
  }

  BottomAppBar _managementBottomAppBar() {
    return BottomAppBar(
      // surfaceTintColor defines the color after elevation is applied.
      surfaceTintColor: Colors.white,
      shape: const CircularNotchedRectangle(),
      padding: const EdgeInsets.only(top: 15.0),
      // color: Theme.of(context).bottomAppBarTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            tooltip: 'Show calendar schedule',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {
              _setPageIndex(0);
            },
          ),
          IconButton(
            tooltip: 'Manage projects',
            icon: const Icon(Icons.create_new_folder_rounded),
            onPressed: () {
              _setPageIndex(1);
            },
          ),
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              _setPageIndex(2);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _navigateEditPage(BuildContext context,
      TaskProvider taskProvider, List<Project> projects) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TaskEditPage(taskProvider: taskProvider, projects: projects),
      ),
    );
  }

  Future<void> _navigateProjectEditPage(
      BuildContext context, ProjectProvider projectProvider,
      [Project? project]) async {
    await Navigator.of(context).push(
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
