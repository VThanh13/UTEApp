import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
        this.y,
        this.xValue,
        this.yValue,
        this.secondSeriesYValue,
        this.thirdSeriesYValue,
        this.pointColor,
        this.size,
        this.text,
        this.open,
        this.close,
        this.low,
        this.high,
        this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}
class PieChartData {
  PieChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class _StatsPageState extends State<StatsPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      new EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  int pageIndex = 0;
  int all_user = 0;
  int all_employee = 0;
  int all_question = 0;
  int all_category = 0;
  TooltipBehavior? _tooltipBehavior;
  List<ChartSampleData>? chartData;
  List<PieChartData>? chartDataPie;
  var departmentName = new Map();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getDataStats();
    getDataColumn();
    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);
    super.initState();
  }

  getDataStats() async {
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) => {
          setState(() {
            all_user = value.size;
          })
        });
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
      setState(() {
        all_employee = value.size;
      })
    });
    await FirebaseFirestore.instance
        .collection('questions')
        .get()
        .then((value) => {
      setState(() {
        all_question = value.size;
      })
    });
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
          value.docs.forEach((element) {
            setState(() {
              departmentName[element.id] = element["name"];
              List<String> list_category = element['category'].cast<String>();
              all_category += list_category.length;
            });
          })
    });
  }

  getDataColumn(){
    chartData = <ChartSampleData>[];
    int dtl = 0;
    int ctl = 0;
    departmentName.forEach((key, value){
      FirebaseFirestore.instance
          .collection('questions')
          .where('department', isEqualTo: value)
          .get()
          .then((values) => {
            setState(() {
              if(values.docs.isEmpty){
                dtl=0;
                ctl=0;
              }
              else{
                values.docs.forEach((element) {
                  if(element['status'] == 'Đã trả lời'){
                    dtl+=1;
                  }
                  else{
                    ctl+=1;
                  }
                });
              }
              chartData?.add(
                  ChartSampleData(
                      x: value,               //Tên khoa
                      y: dtl,      //Đã trả lời
                      yValue: ctl,   //Chưa trả lời
                      secondSeriesYValue: 72,
                      thirdSeriesYValue: 65)
              );
            })
      });
    });
  }
  getDataPie() async{
    chartDataPie = [];
    departmentName.forEach((key, value) {
      setState(() {
        chartDataPie?.add(
            PieChartData(value, 35, Colors.red)
        );
      });
    });
    chartDataPie?.add(
        PieChartData("d", 35, Colors.red));
  }
  Widget getChart(){
    if(pageIndex==0){
      return getStats();
    }
    else if(pageIndex==1){
      return getColumnChart();
    }
    else if(pageIndex==2){
      return getPieChart();
    }
    else{
      return getColumnChart();
    }
  }

  Widget getPieChart(){
    getDataPie();
    return SfCircularChart(
      // Enables the tooltip for all the series in chart
        tooltipBehavior: _tooltipBehavior,
        title: ChartTitle(text: 'Biểu đồ tròn'),
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
          // Initialize line series
          PieSeries<PieChartData, String>(
            // Enables the tooltip for individual series
              enableTooltip: true,
              dataSource: chartDataPie,
              xValueMapper: (PieChartData data, _) => data.x,
              yValueMapper: (PieChartData data, _) => data.y,
              //dataLabelSettings:DataLabelSettings(isVisible : true)
          )
        ],
    );
  }

  Widget getColumnChart(){
    if (departmentName.isEmpty) {
      return Center(
        child: Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator()),
      );
    }
    var size = MediaQuery.of(context).size;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(
          text: 'Thống kê số câu hỏi các khoa'),
      legend: Legend(
          isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat: '{value}',
          maximum: 30,
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getStackedColumnSeries(),
      tooltipBehavior: _tooltipBehavior,
    );
  }
  List<StackedColumnSeries<ChartSampleData, String>> _getStackedColumnSeries() {
    return <StackedColumnSeries<ChartSampleData, String>>[
      StackedColumnSeries<ChartSampleData, String>(
          dataSource: chartData!,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          name: 'Đã trả lời'),
      StackedColumnSeries<ChartSampleData, String>(
          dataSource: chartData!,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.yValue,
          name: 'Chưa trả lời'),
    ];
  }

  Widget getStats(){
    var size = MediaQuery.of(context).size;
    if (all_user == 0 || all_question == 0 || all_employee == 0 || all_category == 0) {
      return Center(
        child: Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        Wrap(
          spacing: 20,
          children: [
            Container(
              width: (size.width - 60) / 2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                      // changes position of shadow
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          all_user.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: (size.width - 60) / 2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                      // changes position of shadow
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                          child: Icon(
                            Icons.question_answer_outlined,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tư vấn viên",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          all_employee.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Wrap(
          spacing: 20,
          children: [
            Container(
              width: (size.width - 60) / 2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                      // changes position of shadow
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                          child: Icon(
                            Icons.question_mark,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Câu hỏi",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          all_question.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: (size.width - 60) / 2,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                      // changes position of shadow
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                          child: Icon(
                            Icons.category,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lĩnh vực",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          all_category.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ]
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.01),
                spreadRadius: 10,
                blurRadius: 3,
                // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 60, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Thống kê",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Icon(Icons.search)
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          getChart(),
        ],
      ),
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.table_chart_rounded,
      Icons.bar_chart,
      Icons.area_chart,
      Icons.add_a_photo,
    ];
    return AnimatedBottomNavigationBar(
      activeColor: Colors.blue,
      splashColor: Colors.grey,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: iconItems,
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
      //other params
    );
  }
  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Color(0xCBCBD5DE),
        bottomNavigationBar: getFooter(),
        body: getBody(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              //selectedTab(4);
            },
            child: Icon(
              Icons.add,
              size: 25,
            ),
            backgroundColor: Colors.pink
            //params
            ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }
}
