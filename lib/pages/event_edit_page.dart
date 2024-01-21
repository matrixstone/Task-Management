import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../model/event.dart';
import '../provider/event_provider.dart';
import '../utils.dart';

class EventEditPage extends StatefulWidget {
  final Event? event;
  EventProvider eventProvider;
  EventEditPage({
    Key? key,
    this.event,
    required this.eventProvider,
  }) : super(key: key);

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? titleController;
  late DateTime from;
  late DateTime to;

  @override
  void initState() {
    super.initState();
    from = widget.event?.fromDate ?? DateTime.now();
    to = widget.event?.toDate ?? DateTime.now().add(const Duration(hours: 1));
    titleController = TextEditingController(text: widget.event?.title);
  }

  @override
  void dispose() {
    titleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Testing loaded event: ${widget.event}');
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(widget.eventProvider),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildTitle(widget.eventProvider),
              buildDateTimePickers(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions(EventProvider eventProvider) => [
        ElevatedButton.icon(
            onPressed: () => saveForm(eventProvider),
            icon: Icon(Icons.done),
            label: Text('Save'))
      ];

  // TODO: Add TextFormField
  Widget buildTitle(EventProvider eventProvider) => TextFormField(
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(eventProvider),
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
  Future saveForm(EventProvider eventProvider) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final event = Event(
        id: widget.event?.id,
        title: titleController!.text,
        description: '',
        fromDate: from,
        toDate: to,
      );
      await eventProvider.addEvent(event).then((value) {
        Navigator.of(context).pop(event);
      });
      // print('Testing addEventResult not complete222');
      // // Navigator.of(context).pop(event);
      // if (addEventResult) {

      // }
      // Navigator.pop();
    }
  }
}
