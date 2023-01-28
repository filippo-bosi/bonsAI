import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/model/sensor.dart';
import 'package:flutter_application/widgets/my_sensor_card.dart';
import 'package:flutter_application/model/weather_forecast.dart';
import 'package:flutter/material.dart';
import '../const/custom_colors.dart';
import '../const/custom_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.user, required this.index})
      : super(key: key);
  final String user;
  final int index;
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<double>? tempList;
  List<double>? rhList;
  List<double>? soilList;
  List<double>? lightList;

  static String collection1Name = 'Users';
  late String docName = widget.user;
  static String collection2Name = 'Plants';

  WeatherService weatherService = WeatherService();
  Weather weather = Weather();

  String weatherCondition = "";
  num temp_c = 0.0;
  num humidity_c = 0.0;

  @override
  void initState() {
    super.initState();
    getWeather("Rome"); // random value to init
  }

  @override
  Widget build(BuildContext context) {
    final sensorRef = FirebaseFirestore.instance
        .collection(collection1Name)
        .doc(docName)
        .collection(collection2Name)
        .withConverter<Sensor>(
          fromFirestore: (snapshots, _) => Sensor.fromJson(snapshots.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );
    int plantIndex = widget.index;
    bool newPlant = false;
    bool outdoor = true;
    //print("OUT $plantIndex");
    return Scaffold(
        body: StreamBuilder<QuerySnapshot<Sensor>>(
      stream: sensorRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.requireData;

        if (plantIndex == -1) {
          plantIndex = data.docs.length - 1;
          newPlant = true;
          //print("AFTER1 $plantIndex");
        }
        if (plantIndex == -1) {
          final plantIndex = data.docs.length - 1;
          const newPlant = true;
          //print("AFTER2 $plantIndex");
        }
        //print("AFTER3 $plantIndex");

        // if (plantIndex == -1) {
        //   plantIndex = data.docs.length - 1;
        // }
        // print("AFTER2 $plantIndex");

        if (tempList == null) {
          tempList = List.filled(5, data.docs[plantIndex].data().temperature,
              growable: true);
        } else {
          tempList!.add(data.docs[plantIndex].data().temperature);
          tempList!.removeAt(0);
        }

        if (rhList == null) {
          rhList = List.filled(5, data.docs[plantIndex].data().humidity,
              growable: true);
        } else {
          rhList!.add(data.docs[plantIndex].data().humidity);
          rhList!.removeAt(0);
        }

        if (soilList == null) {
          soilList = List.filled(5, data.docs[plantIndex].data().soil_moisture,
              growable: true);
        } else {
          soilList!.add(data.docs[plantIndex].data().soil_moisture);
          soilList!.removeAt(0);
        }

        if (lightList == null) {
          lightList = List.filled(5, data.docs[plantIndex].data().light_level,
              growable: true);
        } else {
          lightList!.add(data.docs[plantIndex].data().light_level);
          lightList!.removeAt(0);
        }

        final String plantLocation = data.docs[plantIndex].data().location;
        getWeather(plantLocation);

        if (data.docs[plantIndex].data().humidity > (humidity_c - 8) &&
            data.docs[plantIndex].data().humidity < (humidity_c + 8)) {
          if (data.docs[plantIndex].data().temperature > (temp_c - 5) &&
              data.docs[plantIndex].data().temperature < (temp_c + 5)) {
            outdoor = true;
          } else {
            outdoor = false;
          }
        } else {
          outdoor = false;
        }

        return Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 30),
          child: CustomScrollView(slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Navigator.of(context)
                            //     .popUntil(ModalRoute.withName("/Plants"));
                            if (newPlant == true) {
                              var counter = 0;
                              Navigator.popUntil(context, (route) {
                                return counter++ == 3;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: Image(
                            width: 24,
                            color: Colors.white,
                            image: AssetImage('assets/images/back_arrow.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Plant Parameters',
                            style: kHeadline,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            data.docs[plantIndex].data().commonName,
                            style: kHeadline,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MySensorCard(
                                value: data.docs[plantIndex].data().humidity,
                                unit: '%',
                                name: 'Humidity',
                                assetImage: AssetImage(
                                  'assets/images/humidity_icon.png',
                                ),
                                trendData: rhList!,
                                linePoint: Colors.blueAccent,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MySensorCard(
                                value: data.docs[plantIndex].data().temperature,
                                unit: '°C',
                                name: 'Temperature',
                                assetImage: AssetImage(
                                  'assets/images/temperature_icon.png',
                                ),
                                trendData: tempList!,
                                linePoint: Colors.redAccent,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MySensorCard(
                                value:
                                    data.docs[plantIndex].data().soil_moisture,
                                unit: '',
                                name: 'Soil Moisture',
                                assetImage: AssetImage(
                                  'assets/images/soil_moisture.png',
                                ),
                                trendData: soilList!,
                                linePoint: Color.fromARGB(255, 131, 91, 77),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MySensorCard(
                                value: data.docs[plantIndex].data().light_level,
                                unit: '',
                                name: 'Light',
                                assetImage: AssetImage(
                                  'assets/images/brightness.png',
                                ),
                                trendData: lightList!,
                                linePoint: Colors.yellowAccent,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  shadowColor: Colors.white,
                                  elevation: 24,
                                  color: kMainBG,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 200,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text("Common Name:",
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text("Plant Type: ",
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text("Comfort Level: ",
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text("Water Needs: ",
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                  data.docs[plantIndex]
                                                      .data()
                                                      .commonName,
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  data.docs[plantIndex]
                                                      .data()
                                                      .plantType,
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  data.docs[plantIndex]
                                                      .data()
                                                      .comfort,
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  data.docs[plantIndex]
                                                      .data()
                                                      .waterNeeds,
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 30,
                              ),
                              Text("Plant Location:",
                                  style: kHeadline.copyWith(
                                      color: Colors.white, fontSize: 27)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(outdoor == true ? 'OUTDOOR' : 'INDOOR',
                                  style:
                                      kHeadline.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Go back to Homepage? ",
                        style: kBodyText,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (newPlant == true) {
                            var counter = 0;
                            Navigator.popUntil(context, (route) {
                              return counter++ == 3;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "Go Back",
                          style: kBodyText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    ));
  }

  void getWeather(String plantLocation) async {
    //data.docs[plantIndex].data().location;
    weather = await weatherService.GetWeatherdata(plantLocation);
    if (mounted) {
      setState(() {
        weatherCondition = weather.condition;
        temp_c = weather.temperature;
        humidity_c = weather.humidity;
      });
    }
  }
}
