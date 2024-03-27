import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../model/project.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
  @override
  String toString() {
    return 'ChartData{x: $x, y: $y}';
  }
}

// Shows projects analytics information.
class ReportPage extends StatefulWidget {
  Map<Project, Map<DateTime, double>> projectsToTime;
  int viewLastXDays = 7;

  ReportPage({super.key, required this.projectsToTime});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    var isCardView = true;
    return ListView(
      children: [
        // Shows timeseries chart of how many hours spent on each project in last 7 days.
        SfCartesianChart(
            // Initialize category axis
            primaryXAxis: const CategoryAxis(),
            // primaryYAxis: NumericAxis(),
            legend: const Legend(isVisible: true),
            series:
                // Initialize line series
                _getTimeseriesCartesianChartData()),
        // Shows pie chart of how many hours spent on each project in total
        SfCircularChart(
          title: ChartTitle(
              text: isCardView
                  ? ''
                  : 'Various countries population density and area'),
          legend: Legend(
              isVisible: !isCardView,
              overflowMode: LegendItemOverflowMode.wrap),
          series: _getRadiusPieSeries(),
          onTooltipRender: (TooltipArgs args) {
            final NumberFormat format = NumberFormat.decimalPattern();
            args.text =
                args.dataPoints![args.pointIndex!.toInt()].x.toString() +
                    ' : ' +
                    format.format(args.dataPoints![args.pointIndex!.toInt()].y);
          },
          tooltipBehavior: TooltipBehavior(enable: true),
        )
      ],
    );
  }

  List<CartesianSeries> _getTimeseriesCartesianChartData() {
    List<CartesianSeries> series = <CartesianSeries>[];
    widget.projectsToTime.forEach((project, value) {
      // For each project, sum up the time spent on each day into dateTimeMap.
      Map<String, double> dateTimeMap = {};
      // Initialize dateTimeMap
      DateTime datePointer = DateTime.now().add(const Duration(days: 1));
      for (int i = 0; i < widget.viewLastXDays; i++) {
        datePointer = datePointer.subtract(const Duration(days: 1));
        String dateKey = DateFormat('yyyy-MM-dd').format(datePointer);
        dateTimeMap[dateKey] = 0;
      }

      // Set start date
      DateTime startDate =
          DateTime.now().subtract(Duration(days: widget.viewLastXDays));
      DateTime startDateOnlyFormat =
          DateTime(startDate.year, startDate.month, startDate.day);
      for (MapEntry<DateTime, double> entry in value.entries) {
        if (entry.key.isBefore(startDateOnlyFormat)) {
          continue;
        }
        String dateKey = DateFormat('yyyy-MM-dd').format(entry.key);
        if (dateTimeMap.containsKey(dateKey)) {
          dateTimeMap[dateKey] = dateTimeMap[dateKey]! + entry.value;
        } else {
          dateTimeMap[dateKey] = entry.value;
        }
      }
      List<ChartData> dateAndSpendTime =
          dateTimeMap.entries.map((e) => ChartData(e.key, e.value)).toList();
      dateAndSpendTime.sort((a, b) => a.x.compareTo(b.x));
      series.add(SplineSeries<ChartData, String>(
          dataSource: dateAndSpendTime,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          isVisibleInLegend: true,
          color: project.color,
          name: project.title));
    });
    return series;
  }

  List<PieSeries<ChartData, String>> _getRadiusPieSeries() {
    List<ChartData> projectTime = widget.projectsToTime.entries.map((entry) {
      double accumulativeTime = 0;
      entry.value.forEach((date, time) {
        accumulativeTime += time;
      });
      // return MapEntry(project, accumulativeTime);
      return ChartData(entry.key.title, accumulativeTime);
    }).toList();

    Map<String, Color> projectColors = widget.projectsToTime
        .map((key, value) => MapEntry(key.title, key.color));

    return <PieSeries<ChartData, String>>[
      PieSeries<ChartData, String>(
          dataSource: projectTime,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => projectColors[data.x],
          dataLabelMapper: (ChartData data, _) => data.x,
          startAngle: 100,
          endAngle: 100,
          // pointRadiusMapper: (ChartData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside))
    ];
  }
}
