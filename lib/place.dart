//TODO Aggiornare barre di scala

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mytilex/datetime_selector.dart';

const String apiBase = 'https://api.meteo.uniparthenope.it';

class Item {
  String? urlWcm3;
  String? urlWw3;
  String? urlAiquam;
  String? urlWrf5;
  String? urlRms;
  String? curDirRms5;
  String? curValRms5;
  String? T_Sup;
  String? S_Sup;
  List<DataPoint>? dataPoints;

  String? curDirWrf5;
  String? temperature;
  String? rain;
  String? status;
  String? statusName;
  String? weathIcon;
  String? weathLabel;

  Item({
    this.urlWcm3,
    this.urlAiquam,
    this.urlWw3,
    this.urlRms,
    this.urlWrf5,
    this.curDirRms5,
    this.curValRms5,
    this.T_Sup,
    this.S_Sup,
    this.dataPoints,
    this.curDirWrf5,
    this.temperature,
    this.rain,
    this.status,
    this.statusName,
    this.weathIcon,
    this.weathLabel,
  });
}

Future<Item> getItem(id, date, idxPage) async {
  String urlWcm3 = apiBase + "/products/wcm3/forecast/" + id + "/plot/image?output=conW&date=" + date;
  String urlWw3 = apiBase + "/products/ww33/forecast/" + id + "/plot/image?output=hsdW&date=" + date;
  String urlAiquam = apiBase + "/products/aiq3/forecast/" + id + "/plot/image?output=mciW&date=" + date;
  String urlRms = apiBase + "/products/rms3/forecast/" + id + "/plot/image?output=genW&date=" + date;
  String urlRms3 = apiBase + "/products/rms3/forecast/" + id + "?date=" + date;
  String urlWrf5 = apiBase + "/products/wrf5/forecast/" + id + "?date=" + date;
  String urlWrf5Gen = apiBase + "/products/wrf5/forecast/" + id + "/plot/image?output=genW&date=" + date;

  var element = Item(
    urlWcm3: urlWcm3,
    urlWw3: urlWw3,
    urlAiquam: urlAiquam,
    urlRms: urlRms,
    urlWrf5: urlWrf5Gen,
  );

  final response = await http.get(Uri.parse(urlRms3));
  if (response.statusCode == 200) {
    var dataRms3 = jsonDecode(response.body);
    if (dataRms3["result"] == "ok") {
      String curDirRms3 = dataRms3["scm"].toString() + " kn";
      String curValRms3 = "resources/arrow/" + dataRms3["scs"].toString() + ".png";

      String TSup = dataRms3["sst"].toString() + ' °C';
      String SSup = dataRms3["sss"].toString() + ' PSU [1/1000]';

      List<DataPoint> dataPoints = [];
      if (idxPage == 1) {
        try {
          dataPoints = await getTimeSeriesAIQ(id, date);
        } catch (e) {
          print("Errore nel recupero della timeseries: $e");
          dataPoints = [];
        }
      }

      final response = await http.get(Uri.parse(urlWrf5));
      var dataWrf5 = jsonDecode(response.body);
      if (dataWrf5["result"] == "ok") {
        String curDirWrf5 = dataWrf5["ws10n"].toString() + " Kn - " + dataWrf5["winds"].toString();
        String temp = dataWrf5["t2c"].toString() + " °C";
        String rain = dataWrf5["crh"].toString() + " mm/h";

        String weath = "resources/meteo_icon/" + dataWrf5["icon"].toString();
        String wLabel = dataWrf5["text"]['it-IT'].toString();

        element = Item(
          urlWcm3: urlWcm3,
          urlWw3: urlWw3,
          urlAiquam: urlAiquam,
          urlWrf5: urlWrf5Gen,
          urlRms: urlRms,
          curValRms5: curValRms3,
          curDirRms5: curDirRms3,
          T_Sup: TSup,
          S_Sup: SSup,
          dataPoints: dataPoints,
          curDirWrf5: curDirWrf5,
          temperature: temp,
          rain: rain,
          weathIcon: weath,
          weathLabel: wLabel,
        );
      }
    }
  }
  return element;
}

class DataPoint {
  final DateTime timestamp;
  final int value;

  DataPoint({required this.timestamp, required this.value});
}

Future<List<DataPoint>> getTimeSeriesAIQ(id, date) async {
  String url = apiBase + "/products/aiq3/timeseries/" + id + "?date=" + date + "&hours=24";
  List<DataPoint> dataPoints = [];

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["result"] == "ok") {
        for (var data in data["timeseries"]) {
          String dateString = data["dateTime"];
          int year = int.parse(dateString.substring(0, 4));
          int month = int.parse(dateString.substring(4, 6));
          int day = int.parse(dateString.substring(6, 8));
          int hour = int.parse(dateString.substring(9, 11));
          int minute = int.parse(dateString.substring(11, 13));

          DateTime parsedDate = DateTime.utc(year, month, day, hour, minute);

          dataPoints.add(DataPoint(
            timestamp: parsedDate,
            value: data["mci"] ?? 0,
          ));
        }
      }
    }
  } catch (e) {
    print("Errore durante il recupero della timeseries: $e");
    return [];
  }

  return dataPoints;
}

class PlacePage extends StatefulWidget {
  final String title;
  final String id;
  final String date;
  final int idxPage;

  PlacePage({
    required this.title,
    required this.id,
    required this.date,
    required this.idxPage,
  });

  @override
  PlacePageState createState() => PlacePageState();
}

class PlacePageState extends State<PlacePage> {
  late DateTime selectedDate;
  late Future<Item> _futureItem;

  @override
  void initState() {
    super.initState();
    final d = widget.date.replaceAll('Z', '');

    selectedDate = DateTime.utc(
      int.parse(d.substring(0, 4)), // year
      int.parse(d.substring(4, 6)), // month
      int.parse(d.substring(6, 8)), // day
      int.parse(d.substring(8, 10)), // hour
      0,
    );

    _futureItem = _loadItem();
  }

  Future<Item> _loadItem() {
    final formattedDate = DateFormat("yyyyMMdd'Z'HHmm").format(selectedDate);
    return getItem(widget.id, formattedDate, widget.idxPage);
  }

  Widget buildBarChart(List<DataPoint> dataPoints) {
    if (dataPoints.isEmpty) return SizedBox.shrink();

    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final barGroups = List.generate(dataPoints.length, (i) {
      final dp = dataPoints[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (dp.value + 1).toDouble(),
            color: getBarColor(dp.value + 1),
            width: 16,
          ),
        ],
      );
    });

    double maxY = barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        groupsSpace: 0,
        minY: 0,
        maxY: maxY,
        barGroups: barGroups,

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dp = dataPoints[group.x.toInt()];
              final time = DateFormat('yyyy-MM-dd HH:mm').format(dp.timestamp.toLocal());
              return BarTooltipItem(
                '$time\n',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Indice: ${dp.value + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              "Indice Contaminazione",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                if (v % 1 != 0) return SizedBox.shrink();
                return Text(v.toInt().toString(), style: TextStyle(fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              "Ora",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dataPoints.length) return SizedBox.shrink();

                final screenWidth = MediaQuery.of(context).size.width;
                final totalPoints = dataPoints.length;

                final maxTicks = (screenWidth / 100).floor();
                final skipStep = (totalPoints / maxTicks).ceil();

                if (idx % skipStep != 0) {
                  return SizedBox.shrink();
                }

                final date = dataPoints[idx].timestamp;
                final label = DateFormat('dd/MM HH:mm').format(date);

                if (screenWidth < 600) {
                  return SideTitleWidget(
                    space: 4,
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -math.pi / 6,
                      child: Text(label, style: TextStyle(fontSize: 10)),
                    ),
                  );
                } else {
                  return SideTitleWidget(
                    space: 4,
                    axisSide: meta.axisSide,
                    child: Text(label, style: TextStyle(fontSize: 10)),
                  );
                }
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color getBarColor(int value) {
    if (value == 2) {
      return Color.fromARGB(255, 56, 105, 243);
    } else if (value == 3) {
      return Color.fromARGB(255, 1, 204, 61);
    } else if (value == 4) {
      return Color.fromARGB(255, 252, 255, 84);
    } else if (value == 5) {
      return Color.fromARGB(255, 254, 47, 29);
    } else if (value == 6) {
      return Color.fromARGB(255, 106, 0, 48);
    }
    return Color.fromARGB(255, 213, 254, 255);
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.title;
    var id = widget.id;
    var date = widget.date;
    var idxPage = widget.idxPage;
    var humanReadableDate = DateFormat('dd/MM/yyyy HH:mm').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromRGBO(6, 66, 115, 1.0),
      ),
      body: Column(
        children: [
          DateTimeSelector(
          initialDate: selectedDate,
          onDateChanged: (val) {
            setState(() {
              selectedDate = DateTime.parse(val);
              _futureItem = _loadItem();
            });
          },
        ),
          Expanded(
          child: FutureBuilder(
            future: _futureItem,
            builder: (BuildContext context, AsyncSnapshot<Item> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              else if (snapshot.hasError)
                return Text("${snapshot.error}");
              else {
                var data = snapshot.data;
                String? urlWcm3 = data?.urlWcm3;
                String? urlAiquam = data?.urlAiquam;
                String? urlWw3 = data?.urlWw3;
                String? urlRms = data?.urlRms;
                String? urlWrf = data?.urlWrf5;

                String? curDir = data?.curDirRms5;
                String? curVal = data?.curValRms5;
                String? tSup = data?.T_Sup;
                String? sSup = data?.S_Sup;

                List<DataPoint>? dataPoints = data?.dataPoints;

                String? w10 = data?.curDirWrf5;
                String? t = data?.temperature;
                String? r = data?.rain;
                String? w = data?.weathIcon;
                String? wL = data?.weathLabel;

                Widget chartWidget = SizedBox.shrink();
                if (idxPage == 1 && dataPoints != null && dataPoints.isNotEmpty) {
                  chartWidget = Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: SizedBox(
                      height: 200.0,
                      child: buildBarChart(dataPoints),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Data: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Text(humanReadableDate),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Meteo: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(child: Text(wL ?? ''), flex: 1),
                                Expanded(
                                  child: Image.asset(w ?? '', height: 30),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Vento 10m: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(child: Text(w10 ?? ''), flex: 1),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Temperatura aria: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(child: Text(t ?? ''), flex: 1),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Pioggia: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(child: Text(r ?? ''), flex: 1),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Corrente superficiale: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(child: Text(curDir ?? ''), flex: 1),
                                Expanded(
                                  child: Image.asset(curVal ?? '', height: 30),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Temperatura superficiale: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(child: Text(tSup ?? ''), flex: 1),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Salinità superficiale: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(child: Text(sSup ?? ''), flex: 1),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 20, thickness: 0),
                      Column(
                        children: [
                          if (idxPage == 1) ...[
                            chartWidget,
                            Image.network(
                              urlAiquam ?? '',
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.redAccent,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Map not available!',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white),
                                  ),
                                );
                              },
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                            Image.asset('resources/colorbar/it-IT/bar_aiquam.jpg'),
                            const Divider(height: 20, thickness: 0),
                          ] else ...[
                            Image.network(
                              urlWrf ?? '',
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.redAccent,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Map not available!',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white),
                                  ),
                                );
                              },
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                            Image.asset('resources/colorbar/it-IT/bar_pioggia.jpg'),
                            Image.asset('resources/colorbar/it-IT/bar_nuvole.jpg'),
                            const Divider(height: 20, thickness: 0),
                          ],
                          Image.network(
                            urlWcm3 ?? '',
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.redAccent,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Map not available!',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : 0,
                                ),
                              );
                            },
                          ),
                          Image.asset('resources/colorbar/it-IT/bar_concentrazion.jpg'),
                          const Divider(height: 20, thickness: 0),
                          Image.network(
                            urlRms ?? '',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.redAccent,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Map not available!',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          Image.asset('resources/colorbar/it-IT/bar_corr.jpg'),
                          const Divider(height: 20, thickness: 0),
                          Image.network(
                            urlWw3 ?? '',
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.redAccent,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Map not available!',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          Image.asset('resources/colorbar/it-IT/bar_ww3.jpg'),
                        ],
                      )
                    ],
                  ),
                );
              }
            },
          ),
      ),
        ]
      ),
    );
  }
}
