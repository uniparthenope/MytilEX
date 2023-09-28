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


Future<List> getItems(String date, locations) async {
  List<Rows> list = <Rows>[];

  for (int i=0; i < locations.length; i++){
    final response = await http.get(Uri.parse(apiBase + "/products/rms3/forecast/" + locations[i] + "?date=" + date + "&opt=place"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["result"] == "ok"){
        var id = data["place"]["id"].toString();
        var scs = 'resources/arrow/' + data["forecast"]["scs"].toString() + '.jpg';
        var scm = data["forecast"]["scm"].toString();
        var name = data["place"]["long_name"]["it"].toString();
        var status = 'resources/status/none.png'.toString();

        // Check if user has permission to see status
        final response2 = await http.get(Uri.parse(apiBase + "/products/wcm3/forecast/" + id + "?date=" + date));
        if (response2.statusCode == 200) {
          var data2 = jsonDecode(response2.body);

          if (data2["result"] == "ok"){
            status = 'resources/status/' + data2["forecast"]["sts"].toString() + '.png';
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

  ListLayout({required this.date, required this.locations});

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
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: getItems(date, locations),
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
                      return Card(
                        child: ListTile(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PlacePage(title: item.name, id: item.id, date: date)),
                            );
                          },
                          title: Text(item.name),
                          subtitle: Text(item.curVal + " m/s"),
                          leading: Image(image: AssetImage(item.curDir),height: 50,),
                          trailing: Image(image: AssetImage(item.status),height: 25,),
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