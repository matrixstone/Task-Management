import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/provider/project_provider.dart';

class ColorItem {
  ColorItem(this.name, this.colorCode);
  final String name;
  final int colorCode;
}

class ProjectEditPage extends StatefulWidget {
  final Project? project;
  final ProjectProvider projectProvider;
  const ProjectEditPage({
    super.key,
    this.project,
    required this.projectProvider,
  });

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? titleController;
  List<ColorItem> projectColorList = <ColorItem>[
    ColorItem('Green', 0xff72ba42),
    ColorItem('Blue', 0xff5767cb),
    ColorItem('Orange', 0xfff57d47),
    ColorItem('Purple', 0xff8c75d0)
  ];
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.project?.title);
    selectedColor = Color(projectColorList[0].colorCode);
  }

  @override
  void dispose() {
    titleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        // actions: buildEditingActions(widget.projectProvider),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildTitle(widget.projectProvider),
              const SizedBox(height: 20),
              buildColorSelector(),
              const SizedBox(height: 20),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buildEditingActions(widget.projectProvider)),
              // buildDateTimePickers(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions(ProjectProvider projectProvider) => [
        ElevatedButton.icon(
            onPressed: () => saveForm(projectProvider),
            icon: const Icon(Icons.done),
            label: const Text('Save')),
        ElevatedButton.icon(
            onPressed: () => deleteProject(projectProvider),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'))
      ];

  Widget buildTitle(ProjectProvider projectProvider) => TextFormField(
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(projectProvider),
        controller: titleController,
        validator: (value) =>
            value != null && value.isEmpty ? 'Title cannot be empty' : null,
      );

  Widget buildColorSelector() {
    return DropdownMenu<Color>(
      initialSelection:
          // Container(color: Colors.blue, child: const Text("Blue")),
          Color(projectColorList[0].colorCode),
      helperText: 'Select theme color for project',
      requestFocusOnTap: true,
      label: const Text('Color'),
      // Rounded selection box
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
      ),
      onSelected: (Color? value) {
        // This is called when the user selects an item.
        setState(() {
          selectedColor = value!;
        });
      },
      width: 300,
      dropdownMenuEntries:
          projectColorList.map<DropdownMenuEntry<Color>>((ColorItem item) {
        return DropdownMenuEntry<Color>(
            // value: Container(color: Colors.blue, child: Text(item.name)),
            value: Color(item.colorCode),
            label: item.name,
            style: MenuItemButton.styleFrom(
                foregroundColor: Color(item.colorCode)));
      }).toList(),
    );
  }

  // TODO: Remove double save when editing.
  Future saveForm(ProjectProvider projectProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final project = Project(
        id: widget.project?.id,
        title: titleController!.text,
        description: '',
        color: selectedColor,
      );
      await projectProvider.addProject(project).then((value) {
        Navigator.of(context).pop(project);
      });
    }
  }

  Future deleteProject(ProjectProvider projectProvider) async {
    if (widget.project!.id != null) {
      await projectProvider.deleteProject(widget.project!).then((value) {
        Navigator.of(context).pop();
      });
    } else {
      Navigator.of(context).pop();
    }
  }
}
