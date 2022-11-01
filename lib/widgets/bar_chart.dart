import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatefulWidget {
  final List<Data> data;
  const BarChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: borderData,
          barGroups: barGroups,
          gridData: FlGridData(show: false),
          alignment: BarChartAlignment.center,
          maxY: 10,
          minY: 0,
          groupsSpace: 17),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.red,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Te';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Tu';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4.0,
                child: Text(widget.data.firstWhere((element) => element.id == value).name,
                    style: const TextStyle(
                      color: Color(0xff7589a2),
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    )),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  // final _barsColor = const LinearGradient(
  //   colors: [kPrimary1, kPrimary1],
  //   begin: Alignment.bottomCenter,
  //   end: Alignment.topCenter,
  // );
  List<BarChartGroupData> get barGroups => widget.data
      .map((e) => BarChartGroupData(barsSpace: 2, x: e.id, barRods: [
            BarChartRodData(
              toY: e.y.toDouble(),
              width: 10.0,
              gradient: e.color,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            )
          ]))
      .toList(); //[
  //       BarChartGroupData(
  //         x: 0,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 8,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 1,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 10,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 2,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 14,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 15,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 13,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 10,
  //             gradient: _barsColor,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //     ];
}

// class BarChartSample3 extends StatefulWidget {
//   const BarChartSample3({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => BarChartSample3State();
// }

// class BarChartSample3State extends State<BarChartSample3> {
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.7,
//       child: Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//         color: const Color(0xff2c4260),
//         child: const BarChartWidget(),
//       ),
//     );
//   }
// }
