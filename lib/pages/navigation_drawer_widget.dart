import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NavigationDrawerWidget extends StatefulWidget {
  final Function setCalendarView;
  final Function setPageIndex;
  final int selectedIndex;
  const NavigationDrawerWidget(
      {super.key,
      required this.setCalendarView,
      required this.setPageIndex,
      required this.selectedIndex});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.selectedIndex;
    return Drawer(
      child: Container(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child:
                Text('Task Management', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: const Text('Day'),
            selected: _selectedIndex == 0,
            onTap: () {
              // Update the state of the app
              _onItemTapped(0);
              widget.setCalendarView('day');
              widget.setPageIndex(0);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Week'),
            selected: _selectedIndex == 1,
            onTap: () {
              // Update the state of the app
              _onItemTapped(1);
              widget.setCalendarView('week');
              widget.setPageIndex(0);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Project'),
            selected: _selectedIndex == 2,
            onTap: () {
              // Update the state of the app
              _onItemTapped(2);
              widget.setPageIndex(1);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Report'),
            selected: _selectedIndex == 3,
            onTap: () {
              // Update the state of the app
              _onItemTapped(3);
              widget.setPageIndex(2);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      )),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
