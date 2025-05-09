import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:mytilex/about.dart';
import 'package:mytilex/itemsList.dart';
import 'package:mytilex/datetime_selector.dart';


class MytilEX extends StatefulWidget{

  const MytilEX();

  @override
  _MytilEXState createState() => _MytilEXState();

}

class _MytilEXState extends State<MytilEX>{
  int _selectedIndex = 1;
  String text = "Update";
  List<String> vetLocations = ["VET0000", "VET0130", "VET0010", "VET0020", "VET0150", "VET0051", "VET0055", "VET0052", "VET0054"];
  List<String> vebLocations = ['VEB1500041', 'VEB1500032', 'VEB1500039', 'VEB1500014', 'VEB1500038', 'VEB1500012', 'VEB1500015', 'VEB1500029', 'VEB1500030', 'VEB1500018', 'VEB1500013', 'VEB1500016', 'VEB1500033', 'VEB1500026', 'VEB1500011', 'VEB1500036', 'VEB1500022', 'VEB1500021', 'VEB1500042', 'VEB1500037', 'VEB1500009', 'VEB1500001', 'VEB1500002', 'VEB1500003', 'VEB1500004', 'VEB1500035', 'VEB1500017'];
  var date = DateTime.now().toUtc();

  void refresh() {
    setState(() {});
  }

  List<Widget> _widgetOptions = <Widget>[
    ListLayout(date: DateTime.now().toUtc().toString(), locations: const [], index: 0),
    ListLayout(date: DateTime.now().toUtc().toString(), locations: const [], index: 1),
  ];

  @override
  void initState() {
    date = DateTime(date.year, date.month, date.day, date.hour);

    _widgetOptions = <Widget>[
      ListLayout(date: date.toString(), locations: vetLocations, index: 0),
      ListLayout(date: date.toString(), locations: vebLocations, index: 1),
    ];
    super.initState();
  }

  void _handleRefresh(val) {
    setState(() {
      _widgetOptions = <Widget>[
        ListLayout(date: val, locations: vetLocations, index: 0),
        ListLayout(date: val, locations: vebLocations, index: 1),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    var legendTitle = 'Concentrazione [N° di particelle]';
    var label = 'Conc. Inquinanti';
    if (_selectedIndex == 1) {
      legendTitle = 'Indice contaminazione molluschi';
      label = 'Liv. contaminazione';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MytilEX', style: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, fontFamily: 'Georgia'),),
        backgroundColor: const Color.fromRGBO(6, 66, 115, 1.0),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Informazioni',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
                //MaterialPageRoute(builder: (context) => ItemPage(title: "Test")),
              );
            },
          )
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: DateTimeSelector(
                  initialDate: date,
                  onDateChanged: _handleRefresh,
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Dir. Corrente", style: TextStyle(fontWeight: FontWeight.bold))
                    )),
                    Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))
                        )
                    ),
                  ],
                ),
            ),
            Expanded(
              flex: 10,
              child: Center( child: _widgetOptions.elementAt(_selectedIndex),),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Center(child:Text(legendTitle, style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(3),
                  child: Column(children: [
                    Row(children: [
                      Expanded(flex: 1, child: Image.asset("resources/status/0.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/1.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/2.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/3.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/4.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/5.png", height: 15,)),
                      Expanded(flex: 1, child: Image.asset("resources/status/6.png", height: 15,)),

                    ],),
                    Row(children: const [
                      Expanded(flex: 1, child: Center(child: Text("Ass."))),
                      Expanded(flex: 1, child: Center(child: Text("Molto Bassa"))),
                      Expanded(flex: 1, child: Center(child: Text("Bassa"))),
                      Expanded(flex: 1, child: Center(child: Text("Media"))),
                      Expanded(flex: 1, child: Center(child: Text("Alta"))),
                      Expanded(flex: 1, child: Center(child: Text("Molto Alta"))),
                      Expanded(flex: 1, child: Center(child: Text("Crit."))),
                    ],)
                  ],))
                ],
              ),
            ),
          ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.opacity),
            label: 'Aree',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Molluschi',
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromRGBO(6, 66, 115, 1.0),
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}