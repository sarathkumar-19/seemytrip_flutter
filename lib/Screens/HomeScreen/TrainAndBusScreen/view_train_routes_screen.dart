import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seemytrip/Controller/view_train_routes_controller.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ViewTrainRoutes extends StatelessWidget {
  final String trainNumber;
  final String fromStation;
  final String toStation;
  final ViewTrainRoutesController viewRouteController = Get.put(ViewTrainRoutesController());

  ViewTrainRoutes({required this.trainNumber, required this.fromStation, required this.toStation}) {
    viewRouteController.fetchTrainSchedule(trainNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(viewRouteController.trainSchedule['trainName'] ?? "Train Routes")),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(thickness: 1, color: Colors.grey.shade300),
          Obx(() {
            if (viewRouteController.trainSchedule.isEmpty) {
              return Text("Running Days: N/A", style: TextStyle(fontSize: 16));
            }
            return Text(
              "Running Days: ${viewRouteController.trainSchedule['trainRunsOnMon'] == 'Y' ? 'M ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnTue'] == 'Y' ? 'T ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnWed'] == 'Y' ? 'W ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnThu'] == 'Y' ? 'T ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnFri'] == 'Y' ? 'F ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnSat'] == 'Y' ? 'S ' : ''}"
              "${viewRouteController.trainSchedule['trainRunsOnSun'] == 'Y' ? 'S ' : ''}",
              style: TextStyle(fontSize: 16),
            );
          }),
          Divider(thickness: 1, color: Colors.grey.shade300),
          Expanded(
            child: Obx(() {
              if (viewRouteController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (viewRouteController.trainSchedule.isEmpty) {
                return Center(child: Text("No data available"));
              }

              final stationList = viewRouteController.trainSchedule['stationList'];

              return Timeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0.1,
                  connectorTheme: ConnectorThemeData(
                    thickness: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: stationList.length,
                  contentsBuilder: (_, index) {
                    final stop = stationList[index];
                    final isFirst = stop['stationName'] == fromStation;
                    final isLast = stop['stationName'] == toStation;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Card(
                        color: isFirst
                            ? Colors.red.shade100
                            : isLast
                                ? Colors.blue.shade100
                                : Colors.white,
                        elevation: 2,
                        margin: EdgeInsets.fromLTRB(8, 0, 12, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop['stationName']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isFirst || isLast ? 16 : 14,
                                  color: isFirst
                                      ? Colors.red[800]
                                      : isLast
                                          ? Colors.blue[800]
                                          : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Arr: ${stop['arrivalTime']}", style: TextStyle(fontSize: 12)),
                                  Text("Dep: ${stop['departureTime']}", style: TextStyle(fontSize: 12)),
                                  Text("Halt: ${stop['haltTime']} min", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Distance: ${stop['distance']} km", style: TextStyle(fontSize: 12)),
                                  Text("Day: ${stop['dayCount']}", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  indicatorBuilder: (_, index) {
                    final stop = stationList[index];
                    final isFirst = stop['stationName'] == fromStation;
                    final isLast = stop['stationName'] == toStation;

                    return DotIndicator(
                      size: 24,
                      color: isFirst ? Colors.red : isLast ? Colors.blue : Colors.grey,
                      child: Icon(
                        isFirst || isLast ? Icons.train : Icons.circle,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                  connectorBuilder: (_, index, __) => SolidLineConnector(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
