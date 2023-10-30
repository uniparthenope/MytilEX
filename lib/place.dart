//TODO Aggiornare barre di scala

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

const String apiBase= 'https://api.meteo.uniparthenope.it';

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

  Item({this.urlWcm3, this.urlAiquam, this.urlWw3, this.urlRms, this.urlWrf5,
    this.curDirRms5, this.curValRms5, this.T_Sup, this.S_Sup, this.dataPoints,
    this.curDirWrf5, this.temperature, this.rain, this.status, this.statusName,
    this.weathIcon, this.weathLabel});
}

Future<Item> getItem(id, date, idxPage) async {
  String urlWcm3 = "https://api.meteo.uniparthenope.it/products/wcm3/forecast/" +
      id + "/plot/image?date=" + date;
  String urlWw3 = "https://api.meteo.uniparthenope.it/products/ww33/forecast/" +
      id + "/plot/image?output=hsd&date=" + date;
  String urlAiquam = "https://api.meteo.uniparthenope.it/products/aiq3/forecast/" +
      id + "/plot/image?output=gen&date=" + date;
  String urlRms = "https://api.meteo.uniparthenope.it/products/rms3/forecast/" +
      id + "/plot/image?date=" + date;
  String urlRms3 = "https://api.meteo.uniparthenope.it/products/rms3/forecast/" +
      id + "?date=" + date;
  String urlWrf5 = "https://api.meteo.uniparthenope.it/products/wrf5/forecast/" +
      id + "?date=" + date;
  String urlWrf5Gen = "https://api.meteo.uniparthenope.it/products/wrf5/forecast/" +
      id + "/plot/image?output=gen&date=" + date;

  var element = Item(urlWcm3: urlWcm3, urlWw3: urlWw3, urlAiquam:urlAiquam, urlRms:urlRms, urlWrf5: urlWrf5Gen);

  final response = await http.get(Uri.parse(urlRms3));
  if (response.statusCode == 200) {
    var dataRms3 = jsonDecode(response.body);
    if (dataRms3["result"] == "ok") {
      String curDirRms3 = dataRms3["forecast"]["scm"].toString() + " m/sec";
      String curValRms3 = "resources/arrow/" + dataRms3["forecast"]["scs"].toString() + ".png";

      String TSup = dataRms3["forecast"]["sst"].toString() + ' °C';
      String SSup = dataRms3["forecast"]["sss"].toString() + ' PSU [1/1000]';

      List<DataPoint> dataPoints = [];
      if (idxPage == 1) {
        Future<List<DataPoint>> dataPointsFuture = getTimeSeriesAIQ(id);
        dataPoints = await dataPointsFuture;
      }

      final response = await http.get(Uri.parse(urlWrf5));
      var dataWrf5 = jsonDecode(response.body);
      if (dataWrf5["result"] == "ok") {
        String curDirWrf5 = dataWrf5["forecast"]["ws10n"].toString() + " Kn - " + dataWrf5["forecast"]["winds"].toString();
        String temp = dataWrf5["forecast"]["t2c"].toString() + " °C";
        String rain = dataWrf5["forecast"]["crh"].toString() + " mm/h";

        String weath = "resources/meteo_icon/" + dataWrf5["forecast"]["icon"].toString();
        String wLabel = dataWrf5["forecast"]["text"]['it'].toString();

        element = Item(urlWcm3: urlWcm3, urlWw3: urlWw3, urlAiquam: urlAiquam, urlWrf5: urlWrf5Gen, urlRms: urlRms,
            curValRms5: curValRms3, curDirRms5: curDirRms3, T_Sup: TSup, S_Sup: SSup, dataPoints: dataPoints,
            curDirWrf5: curDirWrf5, temperature: temp, rain: rain, weathIcon: weath, weathLabel: wLabel);
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

Future<List<DataPoint>> getTimeSeriesAIQ(id) async {
  String url = "https://api.meteo.uniparthenope.it/products/aiq3/timeseries/" + id;
  List<DataPoint> dataPoints = [];

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
          value: data["mci"],
        ));
      }
    }
  } else {
    throw Exception('Failed to load data from API');
  }

  return dataPoints;
}

class PlacePage extends StatefulWidget{
  final String title;
  final String id;
  final String date;
  final int idxPage;

  PlacePage({required this.title, required this.id, required this.date, required this.idxPage});

  @override
  PlacePageState createState() => PlacePageState();
}

class PlacePageState extends State<PlacePage>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.title;
    var id = widget.id;
    var date = widget.date;
    var idxPage = widget.idxPage;
    var humanReadableDate = formatData(date);

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color.fromRGBO(6, 66, 115, 1.0),
          title: Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        body: Center(
          child: FutureBuilder(
              future: getItem(id, date, idxPage),
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

                  var series = [
                    charts.Series<DataPoint, DateTime>(
                      id: 'Value',
                      colorFn: (DataPoint data, _) => getColor(data.value),
                      domainFn: (DataPoint data, _) => data.timestamp,
                      measureFn: (DataPoint data, _) => data.value,
                      data: dataPoints ?? [],
                    )
                  ];

                  var chart = charts.TimeSeriesChart(
                    series,
                    animate: true,
                    behaviors: [
                      charts.ChartTitle('Indice contaminazione molluschi'),
                    ],
                    defaultRenderer: charts.BarRendererConfig<DateTime>(
                      groupingType: charts.BarGroupingType.stacked,
                    ),
                  );

                  var chartWidget = Padding(
                    padding: EdgeInsets.all(32.0),
                    child: SizedBox(
                      height: 200.0,
                      child: chart,
                    ),
                  );

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
                                  const Expanded(child: Text('Data: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)), flex: 1,),
                                  Expanded(
                                    child: Text(humanReadableDate), flex: 1,),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(child: Text('Meteo: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)), flex: 2,),
                                  Expanded(child: Text(wL ?? ''), flex: 1,),
                                  Expanded(
                                    child: Image.asset(w ?? '', height: 30,),
                                    flex: 1,),
                                ],
                              ),
                              // Vento 10m
                              Row(
                                children: [
                                  const Expanded(child: Text('Vento 10m: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)), flex: 1,),
                                  Expanded(child: Text(w10 ?? ''), flex: 1,),
                                ],
                              ),
                              // Temperatura
                              Row(
                                children: [
                                  const Expanded(child: Text(
                                      'Temperatura aria: ', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)), flex: 1,),
                                  Expanded(child: Text(t ?? ''), flex: 1,),
                                ],
                              ),
                              // Pioggia
                              Row(
                                children: [
                                  const Expanded(child: Text('Pioggia: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)), flex: 1,),
                                  Expanded(child: Text(r ?? ''), flex: 1,),
                                ],
                              ),

                              Row(
                                children: [
                                  const Expanded(
                                    child: Text('Corrente superficiale: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0)), flex: 2,),
                                  Expanded(child: Text(curDir ?? ''), flex: 1,),
                                  Expanded(child: Image.asset(
                                    curVal ?? '', height: 30,), flex: 1,),

                                ],
                              ),

                              // Temperatura Sup
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text('Temperatura superficiale: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0)), flex: 1,),
                                  Expanded(child: Text(tSup ?? ''), flex: 1,),
                                ],
                              ),
                              // Surface Salinity
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text('Salinità superficiale: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0)), flex: 1,),
                                  Expanded(child: Text(sSup ?? ''), flex: 1,),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20, thickness: 0),

                        Column(
                          children: [
                            if (idxPage == 1) ...[
                              //const Text('Artificial Intelligence-based water Quality Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              chartWidget,
                              Image.network(urlAiquam ?? '',
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
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                          .expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },),
                              Image.asset(
                                  'resources/colorbar/it-IT/bar_aiquam.jpg'),
                              const Divider(height: 20, thickness: 0),
                            ] else
                              ...[
                                //const Text('Weather Research & Forecasting Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                Image.network(urlWrf ?? '',
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
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                            .expectedTotalBytes != null
                                            ? loadingProgress
                                            .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },),
                                Image.asset(
                                    'resources/colorbar/it-IT/bar_pioggia.jpg'),
                                const Divider(height: 20, thickness: 0),
                              ],
                            //const Text('Water quality Community Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                            Image.network(urlWcm3 ?? '',
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
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress != null
                                        ? (loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!)
                                        : 0,
                                  ),
                                );
                              },),
                            Image.asset(
                                'resources/colorbar/it-IT/bar_concentrazion.jpg'),
                            const Divider(height: 20, thickness: 0),

                            //const Text('Regional Ocean Modeling System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                            Image.network(urlRms ?? '', fit: BoxFit.fill,
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
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                            Image.asset(
                                'resources/colorbar/it-IT/bar_corr.jpg'),
                            const Divider(height: 20, thickness: 0),

                            //const Text('WaveWatch III', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                            Image.network(urlWw3 ?? '',
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
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },),
                            Image.asset('resources/colorbar/it-IT/bar_ww3.jpg'),
                          ],
                        )
                      ],
                    ),
                  );
                }
              }
          ),
        )
    );
  }

  charts.Color getColor(int value) {
    if (value == 1) {
      return charts.Color(r: 56, g: 105, b: 243);
    } else if (value == 2) {
      return charts.Color(r: 1, g: 204, b: 61);
    }  else if (value == 3) {
      return charts.Color(r: 252, g: 255, b: 84);
    }  else if (value == 4) {
      return charts.Color(r: 254, g: 47, b: 29);
    }  else if (value == 5) {
      return charts.Color(r: 106, g: 0, b: 48);
    }

    return charts.Color(r: 255, g: 255, b: 255);
  }

  String formatData(dateStr) {
    DateTime parsedDate = DateTime.parse(
        "${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr
            .substring(6, 8)}T${dateStr.substring(9, 11)}:${dateStr.substring(
            11, 13)}:00Z"
    );

    String humanReadableDate = DateFormat('dd/MM/yyyy hh:mm').format(
        parsedDate);

    return humanReadableDate;
  }
}