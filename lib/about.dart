import 'package:flutter/material.dart';

//TODO Improve About
class Team {
  String name;
  String picture;
  String role;
  String mail;

  Team({required this.name, required this.picture, required this.role, required this.mail});
}

List<Team> getTeam(){

  List<Team> list = <Team>[];

  list.add(Team(name: 'Raffaele Montella', picture: 'resources/team/rmontella_64x64.png', role: 'Project Leader', mail: 'raffaele.montella@uniparthenope.it'));
  list.add(Team(name: 'Diana Di Luccio', picture: 'resources/team/ddiluccio_64x64.png', role: 'Data Manager', mail: 'diana.diluccio@uniparthenope.it'));

  list.add(Team(name: 'Gennaro Mellone', picture: 'resources/team/gmellone_64x64.png', role: 'Developer', mail: 'gennaro.mellone@uniparthenope.it'));
  list.add(Team(name: 'Ciro Giuseppe De Vita', picture: 'resources/team/cgdevita_64x64.png', role: 'Developer', mail: 'cirogiuseppe.devita@uniparthenope.it'));

  return list;
}

class AboutPage extends StatelessWidget {
  final List<Team> items = getTeam();

  AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Informazioni",
          style: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, fontFamily: 'Georgia'),
        ),
        backgroundColor: const Color.fromRGBO(6, 66, 115, 1.0),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'MytilEX',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Aleo',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              const Text("https://meteo.uniparthenope.it", style: TextStyle(fontSize: 16.0)),
              const SizedBox(height: 10),
              const Text("Dipartimento di Scienze e Tecnologie", style: TextStyle(fontSize: 16.0)),
              const Text("Università degli Studi di Napoli 'Parthenope'", style: TextStyle(fontSize: 16.0)),
              const SizedBox(height: 20),
              const Image(image: AssetImage('resources/logo_mytilex.png'), height: 300, fit: BoxFit.fill),
              const SizedBox(height: 20),
              const Text(
                'Team:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Aleo',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ...items.map((item) {
                return ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Contact at: ${item.mail}'),
                    ));
                  },
                  title: Text(item.name),
                  subtitle: Text(item.role),
                  leading: Image(image: AssetImage(item.picture), height: 50),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
