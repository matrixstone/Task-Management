import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/provider/project_provider.dart';

import '../model/task.dart';
import '../provider/task_provider.dart';
import '../utils.dart';

class TaskEditPage extends StatefulWidget {
  final Task? task;
  TaskProvider taskProvider;
  List<Project> projects;
  TaskEditPage({
    Key? key,
    this.task,
    required this.taskProvider,
    required this.projects,
  }) : super(key: key);

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? titleController;
  late DateTime from;
  late DateTime to;
  late Project selectedProject;
  late TaskStatus taskStatus;

  @override
  void initState() {
    super.initState();
    from = widget.task?.fromDate ?? DateTime.now();
    to = widget.task?.toDate ?? DateTime.now().add(const Duration(hours: 1));
    titleController = TextEditingController(text: widget.task?.title);
    int selectedProjectIndex = 0;
    if (widget.task != null) {
      selectedProjectIndex = widget.task!.projectId - 1;
    }
    selectedProject = widget.projects[selectedProjectIndex];
    taskStatus = widget.task?.status ?? TaskStatus.notStarted;
  }

  _setDropdownView(Project updatedIndex) {
    setState(() {
      selectedProject = updatedIndex;
    });
  }

  _setTaskStatus(TaskStatus status) {
    setState(() {
      taskStatus = status;
    });
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
        actions: buildEditingActions(widget.taskProvider),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildTitle(widget.taskProvider),
              buildProjectDropDown(widget.projects),
              buildDateTimePickers(),
              buildStatusDropDown(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions(TaskProvider taskProvider) => [
        ElevatedButton.icon(
            onPressed: () => saveForm(taskProvider),
            icon: Icon(Icons.done),
            label: Text('Save'))
      ];

  Widget buildStatusDropDown() {
    return DropdownButton<TaskStatus>(
      items: TaskStatus.values.map((TaskStatus status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name),
        );
      }).toList(),
      value: taskStatus,
      onChanged: (TaskStatus? newValue) {
        _setTaskStatus(newValue!);
      },
    );
  }

  Widget buildProjectDropDown(List<Project> projects) {
    return DropdownButton<Project>(
      items: projects.map((Project project) {
        return DropdownMenuItem(
          value: project,
          child: Text(project.title),
        );
      }).toList(),
      // value: projects[projectDropDownIndex].title,
      value: selectedProject,
      onChanged: (Project? newValue) {
        _setDropdownView(newValue!);
      },
    );
  }

  // TODO: Add TextFormField
  Widget buildTitle(TaskProvider taskProvider) => TextFormField(
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(taskProvider),
        controller: titleController,
        validator: (value) =>
            value != null && value.isEmpty ? 'Title cannot be empty' : null,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildFromAndTo(title: 'From', displayTime: from),
          buildFromAndTo(title: 'To', displayTime: to),
        ],
      );

  Future pickFromDateTime(
      {required String function, required bool pickDate}) async {
    if (function == 'From') {
      final date = await pickDateTime(from, pickDate: pickDate);
      if (date == null) return;
      setState(() {
        from = date;
        if (date.isAfter(to)) {
          to = DateTime(date.year, date.month, date.day, to.hour, to.minute);
        }
      });
    } else {
      final date = await pickDateTime(to, pickDate: pickDate);
      if (date == null) return;
      setState(() => to = date);
    }
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8),
        lastDate: DateTime(2101),
      );

      if (date == null) return null;

      final time = Duration(
        hours: initialDate.hour,
        minutes: initialDate.minute,
      );

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (timeOfDay == null) return null;

      final date = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      return date;
    }
  }

  Widget buildFromAndTo({
    required String title,
    required DateTime displayTime,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(5),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: buildDrwopdownField(
                    text: Utils.toDate(displayTime),
                    onClicked: () =>
                        pickFromDateTime(function: title, pickDate: true),
                  )),
              Expanded(
                  child: buildDrwopdownField(
                text: Utils.toTime(displayTime),
                onClicked: () =>
                    pickFromDateTime(function: title, pickDate: false),
              )),
            ],
          ),
        ],
      );

  Widget buildDrwopdownField(
          {required String text, required VoidCallback onClicked}) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  // TODO: Remove double save when editing.
  Future saveForm(TaskProvider taskProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final task = Task(
        id: widget.task?.id,
        projectId: selectedProject.id!,
        title: titleController!.text,
        description: '',
        fromDate: from,
        toDate: to,
        status: taskStatus,
        backgroundColor: selectedProject.color,
      );
      await taskProvider.addTask(task).then((value) {
        Navigator.of(context).pop(task);
      });
      // // Navigator.of(context).pop(event);
      // if (addEventResult) {

      // }
      // Navigator.pop();
    }
  }
}
