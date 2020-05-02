import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const kTitleTextStyle = TextStyle(
  fontSize: 18,
  color: Colors.white,
);
const kLargeTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.white,
);
const kSmallTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.white,
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dividerColor: Colors.grey,
        scaffoldBackgroundColor: Color(0xFF090C22),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String data;
  int actualCases = 0;
  int deaths = 0;
  int recovered = 0;
  int affectedCountries = 0;
  int deathsToday = 0;
  int casesToday = 0;
  int activeCases = 0;
  int criticalCases = 0;
  int casesPerMillion = 0;
  int updatedTime = 0;

  final formatter = NumberFormat('#,###');

  String readTimeStamp(int timeStamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp);

    var differ = now.difference(date);
    var time = '';

    if (differ.inSeconds <= 0 ||
        differ.inSeconds > 0 && differ.inMinutes == 0 ||
        differ.inMinutes > 0 && differ.inHours == 0 ||
        differ.inHours > 0 && differ.inDays == 0) {
      time = format.format(date);
    } else if (differ.inDays > 0 && differ.inDays < 7) {
      if (differ.inDays == 1) {
        time = differ.inDays.toString() + ' DAY AGO';
      } else {
        time = differ.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (differ.inDays == 7) {
        time = (differ.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (differ.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }

  getData() async {
    http.Response response = await http.get('https://corona.lmao.ninja/v2/all');

    if (response.statusCode == 200) {
      data = response.body;
      setState(() {
        actualCases = jsonDecode(data)['cases'];
        deaths = jsonDecode(data)['deaths'];
        recovered = jsonDecode(data)['recovered'];
        affectedCountries = jsonDecode(data)['affectedCountries'];
        deathsToday = jsonDecode(data)['todayDeaths'];
        casesToday = jsonDecode(data)['todayCases'];
        activeCases = jsonDecode(data)['active'];
        criticalCases = jsonDecode(data)['critical'];
        casesPerMillion = jsonDecode(data)['casesPerOneMillion'];
        updatedTime = jsonDecode(data)['updated'];
      });
    } else {
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            height: 360,
            child: Column(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      'Covid-19 Update'.toUpperCase(),
                      style: kTitleTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Last updated: ${readTimeStamp(updatedTime)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: GridView(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      ReusableCard(
                        icon: FontAwesomeIcons.wheelchair,
                        title: 'Confirmed Cases',
                        numbers: formatter.format(actualCases).toString(),
                      ),
                      ReusableCard(
                        icon: Icons.today,
                        title: 'Today Cases',
                        numbers: formatter.format(casesToday).toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.bookDead,
                        title: 'Deaths',
                        numbers: formatter.format(deaths).toString(),
                      ),
                      ReusableCard(
                        icon: Icons.today,
                        title: 'Today deaths',
                        numbers: deathsToday.toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.male,
                        title: 'Recovered',
                        numbers: formatter.format(recovered).toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.male,
                        title: 'Active',
                        numbers: formatter.format(activeCases).toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.fire,
                        title: 'Critical',
                        numbers: formatter.format(criticalCases).toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.chartLine,
                        title: 'Cases Per One Million',
                        numbers: formatter.format(casesPerMillion).toString(),
                      ),
                      ReusableCard(
                        icon: FontAwesomeIcons.globe,
                        title: 'Affected Countries',
                        numbers: affectedCountries.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  final String numbers;
  final String title;
  final IconData icon;
  ReusableCard(
      {@required this.numbers, @required this.title, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(59, 56, 88, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: kLargeTextStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            numbers,
            style: kSmallTextStyle,
          ),
        ],
      ),
    );
  }
}
