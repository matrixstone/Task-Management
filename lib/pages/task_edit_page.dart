import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../model/task.dart';
import '../provider/task_provider.dart';
import '../utils.dart';

class TaskEditPage extends StatefulWidget {
  final Task? task;
  TaskProvider taskProvider;
  TaskEditPage({
    Key? key,
    this.task,
    required this.taskProvider,
  }) : super(key: key);

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? titleController;
  late DateTime from;
  late DateTime to;

  @override
  void initState() {
    super.initState();
    from = widget.task?.fromDate ?? DateTime.now();
    to = widget.task?.toDate ?? DateTime.now().add(const Duration(hours: 1));
    titleController = TextEditingController(text: widget.task?.title);
  }

  @override
  void dispose() {
    titleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Testing loaded event: ${widget.task}');
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
              buildDateTimePickers(),
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

  // TODO: Add TextFormField
  Widget buildTitle(TaskProvider taskProvider) => TextFormField(
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
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
        title: titleController!.text,
        description: '',
        fromDate: from,
        toDate: to,
      );
      await taskProvider.addTask(task).then((value) {
        Navigator.of(context).pop(task);
      });
      // print('Testing addEventResult not complete222');
      // // Navigator.of(context).pop(event);
      // if (addEventResult) {

      // }
      // Navigator.pop();
    }
  }
}
