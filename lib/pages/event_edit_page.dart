import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../model/event.dart';
import '../utils.dart';

class EventEditPage extends StatefulWidget {
  final Event? event;
  const EventEditPage({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  late DateTime from;
  late DateTime to;

  @override
  void initState() {
    super.initState();
    from = widget.event?.from ?? DateTime.now();
    to = widget.event?.to ?? DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: CloseButton(),
          actions: buildEditingActions(),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildTitle(),
                buildDateTimePickers(),
              ],
            ),
          ),
        ),
      );

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
            onPressed: () {}, icon: Icon(Icons.done), label: Text('Save'))
      ];
  Widget buildTitle() => TextFormField(
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) {},
        controller: titleController,
        validator: (value) =>
            value != null && value.isEmpty ? 'Title cannot be empty' : null,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildFromAndTo(title: 'From', displayTime: from),
          buildFromAndTo(title: 'To', displayTime: to),
          // buildTo(),
        ],
      );
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
                    onClicked: () {},
                  )),
              Expanded(
                  child: buildDrwopdownField(
                text: Utils.toTime(displayTime),
                onClicked: () {},
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
}