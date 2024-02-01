import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/provider/project_provider.dart';

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
        leading: CloseButton(),
        actions: buildEditingActions(widget.projectProvider),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildTitle(widget.projectProvider),
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
            icon: Icon(Icons.done),
            label: Text('Save'))
      ];

  Widget buildTitle(ProjectProvider projectProvider) => TextFormField(
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(projectProvider),
        controller: titleController,
        validator: (value) =>
            value != null && value.isEmpty ? 'Title cannot be empty' : null,
      );

  // TODO: Remove double save when editing.
  Future saveForm(ProjectProvider projectProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final project = Project(
        id: widget.project?.id,
        title: titleController!.text,
        description: '',
      );
      await projectProvider.addProject(project).then((value) {
        Navigator.of(context).pop(project);
      });
    }
  }
}
