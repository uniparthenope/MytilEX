import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mytilex/place.dart';

const String apiBase= 'https://api.meteo.uniparthenope.it';

class Rows {
  String? id;
  String? name;
  String? curDir;
  String? curVal;
  String? status;
  String? dt;

  Rows({this.id, this.name, this.curDir, this.curVal, this.status});
}

Future<List<Rows>> getItems(String date, List<String> locations, int index) async {
  List<Future<Rows?>> futures = locations.map((loc) async {
    try {
      final resp1 = await http.get(Uri.parse('$apiBase/products/rms3/forecast/$loc?date=$date&opt=place'));
      if (resp1.statusCode != 200) return null;
      final data = jsonDecode(resp1.body);
      if (data['result'] != 'ok') return null;

      final id     = data['place']['id'].toString();
      final scsVal = data['scs']?.toString() ?? 'null';
      final scs    = (scsVal=='0' || scsVal=='null')
          ? 'resources/arrow/null.png'
          : 'resources/arrow/$scsVal.png';
      final scm    = data['scm'].toString();
      final name   = data['place']['long_name']['it'].toString();

      var urlStatus = (index == 1)
          ? '$apiBase/products/aiq3/forecast/$id?date=$date'
          : '$apiBase/products/wcm3/forecast/$id?date=$date';

      final resp2 = await http.get(Uri.parse(urlStatus));
      String status = 'resources/status/none.png';
      if (resp2.statusCode == 200) {
        final d2 = jsonDecode(resp2.body);
        if (d2['result']=='ok') {
          if (index==1) {
            final mci = d2['mci']!=null ? (d2['mci']+1).toString() : '0';
            status = 'resources/status/$mci.png';
          } else {
            final sts = d2['sts']?.toString() ?? 'null';
            status = 'resources/status/$sts.png';
          }
        }
      }

      return Rows(
        id:     id,
        name:   name,
        curDir: scs,
        curVal: scm,
        status: status,
      );
    } catch (e) {
      return null;
    }
  }).toList();

  final results = await Future.wait(futures);

  final list = results.where((r)=> r!=null).cast<Rows>().toList()
    ..sort((a,b)=> a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

  return list;
}

class ListLayout extends StatefulWidget {
  final String date;
  final List<String> locations;
  final int index;

  ListLayout({required this.date, required this.locations, required this.index});

  @override
  _ListLayoutState createState() => _ListLayoutState();
}

class _ListLayoutState extends State<ListLayout> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var date = formatData(widget.date);
    var locations = widget.locations;
    var idxPage = widget.index;

    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: getItems(date, locations, idxPage),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
              } else {
                  var items = snapshot.data;
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var item = items![index];
                      var title = item.name;
                      var subtitle = "";

                      if (idxPage == 1) {
                        var split = title.split("-");
                        title = split[0].trim();
                        subtitle = split.sublist(1).join('-').trim();
                      }
                      return Card(
                        child: ListTile(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PlacePage(title: item.name, id: item.id, date: date, idxPage: idxPage)),
                            );
                          },
                          title: Text(title),
                          subtitle: Text(subtitle),
                          leading: Column(children: [
                            Image(image: AssetImage(item.curDir), height: 30,),
                            Text(item.curVal + " kn", style: TextStyle(fontSize: 12))
                          ]),
                          trailing: Image(image: AssetImage(item.status), height: 25,),
                        ),
                      );
                    },
                    itemCount: items == null ? 0 : items.length,
                  );
              }
            }
        )
      )
    );
  }

  String formatData(data){
    final _date = DateTime.parse(data);
    final DateFormat formatter = DateFormat('yyyyMMdd HH00');
    final String formattedDate = formatter.format(_date).replaceAll(" ", "Z");

    return formattedDate;
  }
}