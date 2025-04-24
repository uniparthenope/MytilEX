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


Future<List> getItems(String date, locations, int index) async {
  List<Rows> list = <Rows>[];

  for (int i=0; i < locations.length; i++){
    final response = await http.get(Uri.parse(apiBase + "/products/rms3/forecast/" + locations[i] + "?date=" + date + "&opt=place"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["result"] == "ok"){
        var id = data["place"]["id"].toString();
        var scsValue = data["scs"]?.toString() ?? 'null';
        var scs = (scsValue == '0' || scsValue == 'null')
            ? 'resources/arrow/null.png'
            : 'resources/arrow/$scsValue.png';
        var scm = data["scm"].toString();
        var name = data["place"]["long_name"]["it"].toString();
        var status = 'resources/status/none.png'.toString();

        var urlStatus = apiBase + "/products/wcm3/forecast/" + id + "?date=" + date;
        if (index == 1) {
          urlStatus = apiBase + "/products/aiq3/forecast/" + id + "?date=" + date;
        }
        final response2 = await http.get(Uri.parse(urlStatus));
        if (response2.statusCode == 200) {
          var data2 = jsonDecode(response2.body);

          if (data2["result"] == "ok"){
            if (index == 1) {
              var mciValue = data2["mci"] != null ? (data2["mci"] + 1).toString() : "0";
              status = 'resources/status/' + mciValue + '.png';
            }
            else {
              var stsValue = data2["sts"] != null ? data2["sts"].toString() : "null";
              status = 'resources/status/' + stsValue + '.png';
            }
          }
        }

        var item = Rows(id: id, name: name, curDir: scs, curVal: scm, status: status);
        list.add(item);
      }
    }
  }

  list.sort((a, b) {
    return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
  });

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
                            Text(item.curVal + " m/s", style: TextStyle(fontSize: 12))
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