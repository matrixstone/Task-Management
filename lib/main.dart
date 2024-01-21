import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:task_management/pages/calendar_widget.dart';
import 'package:task_management/pages/event_edit_page.dart';
import 'package:task_management/pages/navigation_drawer_widget.dart';
import 'package:task_management/provider/event_provider.dart';
import 'package:task_management/model/event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  databaseFactory = databaseFactoryFfiWeb;

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    // return FutureProvider<List<Event>>(
    //   create: (context) => EventProvider().getAllEvents(),
    //   initialData: List<Event>.empty(),
    //   child: MaterialApp(
    //     title: 'Flutter Demo',
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(
    //       // This is the theme of your application.
    //       //
    //       // Try running your application with "flutter run". You'll see the
    //       // application has a blue toolbar. Then, without quitting the app, try
    //       // changing the primarySwatch below to Colors.green and then invoke
    //       // "hot reload" (press "r" in the console where you ran "flutter run",
    //       // or simply save your changes to "hot reload" in a Flutter IDE).
    //       // Notice that the counter didn't reset back to zero; the application
    //       // is not restarted.
    //       primarySwatch: Colors.blue,
    //     ),
    //     home: const MainPage(),
    //   ),
    // );
    // return ChangeNotifierProvider(
    //   create: (conntext) => EventProvider(),
    //   child: FutureProvider<List<Event>>(
    //     create: (context) => EventProvider().getAllEvents(),
    //     initialData: List<Event>.empty(),
    //     child: MaterialApp(
    //       title: 'Flutter Demo',
    //       debugShowCheckedModeBanner: false,
    //       theme: ThemeData(
    //         // This is the theme of your application.
    //         //
    //         // Try running your application with "flutter run". You'll see the
    //         // application has a blue toolbar. Then, without quitting the app, try
    //         // changing the primarySwatch below to Colors.green and then invoke
    //         // "hot reload" (press "r" in the console where you ran "flutter run",
    //         // or simply save your changes to "hot reload" in a Flutter IDE).
    //         // Notice that the counter didn't reset back to zero; the application
    //         // is not restarted.
    //         primarySwatch: Colors.blue,
    //       ),
    //       home: const MainPage(),
    //     ),
    //   ),
    // );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentView = 'day';

  _setCalendarView(String view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    int navigationBarIndex = 0;
    if (currentView == 'week') {
      navigationBarIndex = 1;
    }

    return Scaffold(
        drawer: NavigationDrawerWidget(
            setCalendarView: _setCalendarView,
            selectedIndex: navigationBarIndex),
        appBar: AppBar(
          title: const Text('Task Management'),
          centerTitle: true,
        ),
        body: Calendar(view: currentView),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateEditPage(context),
          tooltip: 'Add Task',
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _navigateEditPage(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EventEditPage(),
      ),
    );
  }
}
