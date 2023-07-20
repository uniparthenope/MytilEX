import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:html_unescape/html_unescape.dart';
import 'package:mytilex/mytilex.dart';
import 'package:mytilex/about.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

var isLogged = false;
const String apiBase= 'https://api.meteo.uniparthenope.it';

Future<String> getMessage() async {
  final response = await http
      .get(Uri.parse(apiBase + "/legal/disclaimer?lang=it-IT"));

  if (response.statusCode == 200) {
    //log(response.body);
    var message = jsonDecode(response.body);
    var unescape = HtmlUnescape();
    return unescape.convert(message['i18n']['it-IT']['disclaimer']);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    return "";
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MytilEX',
        theme: ThemeData(
          // Define the default brightness and colors.
            colorScheme: const ColorScheme.light().copyWith(primary:  const Color.fromRGBO(0, 96, 160, 1.0)),
            canvasColor: const Color.fromRGBO(229, 233, 236, 1.0),

            // Define the default font family.
            fontFamily: 'Georgia',

            // Define the default `TextTheme`. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: const TextTheme(
              headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            )
        ),
        home: FutureBuilder(
            future: getMessage(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot){

              final message = snapshot.data.toString();
              return Scaffold(
                  appBar: AppBar(
                    title: const Text("MytilEX"),
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
                  body: Container(
                      padding: const EdgeInsets.only(left: 10,top: 5, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(image: AssetImage('resources/logo_mytilex.png')),
                          Text(message, textAlign: TextAlign.justify),
                          Container(
                              padding: const EdgeInsets.only(top:20, left:20, right:20),
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MytilEX()),
                                      );
                                    },
                                    child: const Text('Accetta e continua'),
                                  )
                                ],
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                  onPressed: ()async{
                                    String email = Uri.encodeComponent("mytilex@uniparthenope.it");
                                    String subject = Uri.encodeComponent("Segnalazione bug in app MytilEX");
                                    String body = Uri.encodeComponent("");
                                    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
                                    if (await launchUrl(mail)) {
                                      //email app opened
                                    }else{
                                      //email app is not opened
                                    }
                                  },
                                  child: const Text("Segnala malfunzionamenti")
                              ),
                            ),
                          )
                        ],
                      )
                  )
              );
            }
        )
    );
  }
}