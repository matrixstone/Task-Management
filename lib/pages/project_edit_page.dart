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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.project?.title);
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
        actions: buildEditingActions(widget.projectProvider),
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
              const SizedBox(height: 2),
              buildColorSelector(),
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
            label: const Text('Save'))
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
    List<ColorItem> list = <ColorItem>[
      ColorItem('Green', 0xff72ba42),
      ColorItem('Blue', 0xff5767cb),
      ColorItem('Orange', 0xfff57d47),
      ColorItem('Purple', 0xff8c75d0)
    ];

    return DropdownMenu<Container>(
      initialSelection: Container(color: Colors.blue, child: const Text("one")),
      onSelected: (Container? value) {
        // This is called when the user selects an item.
        // setState(() {
        //   dropdownValue = value!;
        // });
      },
      dropdownMenuEntries:
          list.map<DropdownMenuEntry<Container>>((ColorItem item) {
        return DropdownMenuEntry<Container>(
            value: Container(color: Colors.blue, child: Text(item.name)),
            label: item.name,
            style: MenuItemButton.styleFrom(
                backgroundColor: Color(item.colorCode)));
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
        color: Colors.blue,
      );
      await projectProvider.addProject(project).then((value) {
        Navigator.of(context).pop(project);
      });
    }
  }
}
