import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:mytilex/about.dart';
import 'package:mytilex/itemsList.dart';


class MytilEX extends StatefulWidget{

  const MytilEX();

  @override
  _MytilEXState createState() => _MytilEXState();

}

class _MytilEXState extends State<MytilEX>{
  int _selectedIndex = 1;
  String text = "Update";
  List<String> vetLocations = ["VET0130", "VET0020", "VET0021", "VET0072", "VET0071", "VET0100", "VET0062", "VET0150", "VET0055", "VET0054", "VET0056", "VET0051", "VET0050", "VET0053", "VET0052", "VET0121", "VET0123", "VET0122", "VET0125", "VET0124", "VET0000", "VET0031", "VET0030", "VET0140", "VET0061", "VET0063", "VET0064", "VET0110", "VET0010", "VET0160", "VET0057", "VET0042", "VET0041"];
  List<String> vebLocations = ["VEB1500030", "VEB1500029", "VEB1500015", "VEB1500012", "VEB1500013", "VEB1500018", "VEB1500038", "VEB1500014","VEB1500022","VEB1500032", "VEB1500041", "VEB1500026", "VEB1500033", "VEB1500016"];
  var date = DateTime.now().toUtc();

  void refresh() {
    setState(() {});
  }

  List<Widget> _widgetOptions = <Widget>[
    ListLayout(date: DateTime.now().toUtc().toString(), locations: const []),
    ListLayout(date: DateTime.now().toUtc().toString(), locations: const []),
  ];

  @override
  void initState() {
    date = DateTime(date.year, date.month, date.day, date.hour);

    _widgetOptions = <Widget>[
      ListLayout(date: date.toString(), locations: vetLocations),
      ListLayout(date: date.toString(), locations: vebLocations),
    ];
    super.initState();
  }

  void _handleRefresh(val) {
    setState(() {
      _widgetOptions = <Widget>[
        ListLayout(date: val, locations: vetLocations),
        ListLayout(date: val, locations: vebLocations),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MytilEX', style: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, fontFamily: 'Georgia'),),
        backgroundColor: const Color.fromRGBO(0, 96, 160, 1.0),
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
                child: DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue: date.toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: const Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  onChanged: (val) => {
                    _handleRefresh(val),
                  },
                  validator: (val) {
                    return null;
                  },
                  onSaved: (val) => {
                    _handleRefresh(val),
                  },
                )
            ),
            Padding(
              padding: const EdgeInsets.all(5),
                child: Row(
                  children: const [
                    Expanded(flex: 1, child: Text("Dir. Vento", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 5, child: Center(child: Text("Nome", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 2, child: Text("Conc. Inquinanti", style: TextStyle(fontWeight: FontWeight.bold))),
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
                  const Center(child:Text("Legenda Inquinanti:", style: TextStyle(fontWeight: FontWeight.bold))),
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
        backgroundColor: const Color.fromRGBO(0, 100, 160, 1.0),
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