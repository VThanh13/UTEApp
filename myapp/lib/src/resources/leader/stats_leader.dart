import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsLeaderPage extends StatefulWidget {
  const StatsLeaderPage({super.key});

  @override
  State<StatsLeaderPage> createState() => _StatsPageState();
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

  /// Holds datatables/text value mapper of the datapoint
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

class _StatsPageState extends State<StatsLeaderPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  EmployeeModel currentEmployee = EmployeeModel();
  int pageIndex = 0;
  int allUser = 0;
  int allEmployee = 0;
  int allQuestion = 0;
  int allCategory = 0;
  TooltipBehavior? _tooltipBehavior;
  List<ChartSampleData>? chartData;
  List<PieChartData>? chartDataPie;
  var departmentName = {};
  late List<String> listCategory;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getCurrentEmployee();
    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);
    super.initState();
  }
  getCurrentEmployee() async {
    await FirebaseFirestore.instance
      .collection('employee')
      .where("id", isEqualTo: userAuth.uid)
      .get()
      .then((value) => {
        setState(() {
          currentEmployee.id = value.docs.first['id'];
          currentEmployee.name = value.docs.first['name'];
          currentEmployee.email = value.docs.first['email'];
          currentEmployee.image = value.docs.first['image'];
          currentEmployee.password = value.docs.first['password'];
          currentEmployee.phone = value.docs.first['phone'];
          currentEmployee.department = value.docs.first['department'];
          currentEmployee.category = value.docs.first['category'].cast<String>();
          currentEmployee.roles = value.docs.first['roles'];
          currentEmployee.status = value.docs.first['status'];
        })
      });
    await getDataStats();
  }
  getDataStats() async {
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) => {
          setState(() {
            allUser = value.size;
          })
        });
    await FirebaseFirestore.instance
        .collection('employee')
        .where("department", isEqualTo: currentEmployee.department)
        .get()
        .then((value) => {
      setState(() {
        allEmployee = value.size;
      })
    });
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where("department", isEqualTo: currentEmployee.department)
        .get()
        .then((value) => {
      setState(() {
        allQuestion = value.size;
      })
    });
    await FirebaseFirestore.instance
        .collection('departments')
        .where("id", isEqualTo: currentEmployee.department)
        .get()
        .then((value) => {
        setState(() {
          listCategory = value.docs.first['category'].cast<String>();
          allCategory = listCategory.length;
        })
    });
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
          value.docs.forEach((element) {
            setState(() {
              departmentName[element.id] = element["name"];
              // List<String> list_category = element['category'].cast<String>();
              // all_category += list_category.length;
            });
          })
    });
    await getDataColumn();
    await getDataPie();
  }

  getDataColumn(){
    chartData = <ChartSampleData>[];

    int dtl2=0;
    int ctl2=0;
    FirebaseFirestore.instance
        .collection('chat_room')
        .where('department', isEqualTo: currentEmployee.department)
        .where('category', isEqualTo: "")
        .get()
        .then((values) => {
      setState(() {
        if(values.docs.isEmpty){
          dtl2=0;
          ctl2=0;
        }
        else{
          for (var element in values.docs) {
            if(element['status'] == 'Chưa trả lời'){
              ctl2+=1;
            }
            else{
              dtl2+=1;
            }
          }
        }
        chartData?.add(
            ChartSampleData(
                x: "Còn lại",   //Tên lĩnh vực
                y: dtl2,        //Đã trả lời
                yValue: ctl2,   //Chưa trả lời
                secondSeriesYValue: 72,
                thirdSeriesYValue: 65)
        );
        dtl2=0;
        ctl2=0;
      })
    });

    int dtl;
    int ctl;
    for (var category in listCategory) {
      dtl=0;
      ctl=0;
      FirebaseFirestore.instance
          .collection('chat_room')
          .where('department', isEqualTo: currentEmployee.department)
          .where('category', isEqualTo: category)
          .get()
          .then((values) => {
            setState(() {
              if(values.docs.isEmpty){
                dtl=0;
                ctl=0;
              }
              else{
                for (var element in values.docs) {
                  if(element['status'] == 'Chưa trả lời'){
                    ctl+=1;
                  }
                  else{
                    dtl+=1;
                  }
                }
              }
              chartData?.add(
                  ChartSampleData(
                      x: category,   //Tên lĩnh vực
                      y: dtl,        //Đã trả lời
                      yValue: ctl,   //Chưa trả lời
                      secondSeriesYValue: 72,
                      thirdSeriesYValue: 65)
              );
              dtl=0;
              ctl=0;
            })
      });
    }

  }
  getDataPie() async{
    chartDataPie = [];
    departmentName.forEach((key, value) {
      FirebaseFirestore.instance
          .collection('employee')
          .where('department', isEqualTo: key)
          .get()
          .then((values) => {
        setState(() {
          if(values.docs.isEmpty){
            chartDataPie?.add(
                PieChartData(value, 0, Colors.red)
            );
          }
          else{
            chartDataPie?.add(
                PieChartData(value, values.docs.length.toDouble(), Colors.red)
            );
          }
        }),
      });
    });
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
    return SfCircularChart(
      // Enables the tooltip for all the series in chart
        tooltipBehavior: _tooltipBehavior,
        title: ChartTitle(text: 'Statistics consultant'),
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
    var size = MediaQuery.of(context).size;
    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      title: ChartTitle(
          text: 'Statistics of the number of questions in each field'),
      legend: Legend(
          isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 1),
        maximumLabelWidth: 20,
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
          name: 'Answered'),
      StackedColumnSeries<ChartSampleData, String>(
          dataSource: chartData!,
          xValueMapper: (ChartSampleData sales, _) => sales.x as String,
          yValueMapper: (ChartSampleData sales, _) => sales.yValue,
          name: 'Not answered'),
    ];
  }

  Widget getStats(){
    var size = MediaQuery.of(context).size;
    if (allUser == 0 || allQuestion == 0 || allEmployee == 0 || allCategory == 0 || departmentName.isEmpty) {
      return const Center(
        child: SizedBox(
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
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "User",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          allUser.toString(),
                          style: const TextStyle(
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
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: const Center(
                          child: Icon(
                            Icons.question_answer_outlined,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Counselors",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          allEmployee.toString(),
                          style: const TextStyle(
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
        const SizedBox(
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
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: const Center(
                          child: Icon(
                            Icons.question_mark,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Question",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          allQuestion.toString(),
                          style: const TextStyle(
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
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: const Center(
                          child: Icon(
                            Icons.category,
                            color: Colors.white,
                          )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Field",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          allCategory.toString(),
                          style: const TextStyle(
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

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                //color: Colors.grey.withOpacity(0.01),
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
                    children: const [
                      Text(
                        "Statistical",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Icon(Icons.search)
                    ],
                  ),
                  // SizedBox(
                  //   height: 25,
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(
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
      Icons.pie_chart,
      Icons.bubble_chart,
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
        backgroundColor: const Color(0xCBCBD5DE),
        bottomNavigationBar: getFooter(),
        body: getBody(),
        // floatingActionButton: FloatingActionButton(
        //     onPressed: () {
        //       //selectedTab(4);
        //     },
        //     backgroundColor: Colors.blueAccent,
        //     child: const Icon(
        //       Icons.add,
        //       size: 25,
        //     )
        //     //params
        //     ),
        // floatingActionButtonLocation:
        //     FloatingActionButtonLocation.centerDocked);
    );
  }
}
