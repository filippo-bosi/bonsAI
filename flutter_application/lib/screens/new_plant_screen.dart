import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/screens/dashboard_screen.dart';
import 'package:flutter_application/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/my_text_field.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../model/localization_controller.dart';

class AddNewPlantScreen extends StatefulWidget {
  const AddNewPlantScreen({Key? key, required this.user}) : super(key: key);
  final String user;

  @override
  _AddNewPlantScreenState createState() => _AddNewPlantScreenState();
}

class _AddNewPlantScreenState extends State<AddNewPlantScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final GlobalKey _locationKey = GlobalKey();
  late String _selectedPlant;
  //late LocationController controller = LocationController();
  String? currLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 30),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Image(
                              width: 24,
                              color: Colors.white,
                              image: AssetImage('assets/images/back_arrow.png'),
                            ),
                          ),
                          Text(
                            "Add a new Plant", //choose name, type and location in this page
                            style: kHeadline,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Almost done!",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              "One more step to unlock BonsAI's full potential! First, choose the type of plant you want BonsAI to care for. Then, allow BonsAI to access your device location to unlock our advanced features and ensure the best care for your plants.",
                              style: kBodyText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Form(
                            key: this._formKey,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: <Widget>[
                                  TypeAheadFormField(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: this._typeAheadController,
                                      style: kBodyText.copyWith(
                                          color: Colors.white),
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        hintText: "Plant Type",
                                        hintStyle: kBodyText,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      return BackendService.getSuggestions(
                                          pattern);
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        title: Text(suggestion.toString()),
                                      );
                                    },
                                    transitionBuilder:
                                        (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      this._typeAheadController.text =
                                          suggestion.toString();
                                      //return await getPlantNames();
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please select a plant!';
                                      }
                                    },
                                    onSaved: (value) =>
                                        this._selectedPlant = value!,
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GetBuilder<LocationController>(
                              init: LocationController(),
                              builder: (controller) {
                                return Center(
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator()
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyTextButton(
                                                  buttonName:
                                                      'Get Current Location',
                                                  onTap: () {
                                                    controller
                                                        .getCurrentLocation();
                                                    final String? currLocation =
                                                        controller
                                                            .currentLocation;
                                                  },
                                                  bgColor: Colors.white,
                                                  textColor: Colors.black87),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32.0),
                                                child: TextField(
                                                  controller: this
                                                      ._locationController
                                                    ..text = (controller
                                                                .currentLocation ==
                                                            null
                                                        ? 'Location Not Set'
                                                        : controller
                                                            .currentLocation!),
                                                  style: kBodyText.copyWith(
                                                      color: Colors.white),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(20),
                                                    hintText: "Location",
                                                    hintStyle: kBodyText,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                  ),
                                                ),

                                                // Text(
                                                //   controller.currentLocation ==
                                                //           null
                                                //       ? 'Location Not Set'
                                                //       : controller
                                                //           .currentLocation!,
                                                //   style: kBodyText4,
                                                //   textAlign: TextAlign.center,
                                                // ),
                                              ),
                                            ],
                                          ));
                              }),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "All Done? ",
                          style: kBodyText,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MyTextButton(
                      buttonName: 'Next',
                      onTap: () {
                        if (this._formKey.currentState!.validate()) {
                          this._formKey.currentState!.save();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('You selected ${this._selectedPlant}')));
                          addPlantFirestore(
                            username: widget.user,
                            commonName: _typeAheadController.text,
                            location: _locationController.text,
                          );
                          Timer(Duration(seconds: 4), () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DashboardScreen(
                                          user: widget.user, index: -1)));
                            });
                          });
                        }
                      },
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future addPlantFirestore(
      {required String username,
      required String commonName,
      required String? location}) async {
    int i = await plantsCounter(username: username);
    //String? currLocation = await controller.currentLocation;
    final docUser = FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .collection("Plants")
        .doc("Plant_" + (i + 1).toString());

    String plantType = await FirebaseFirestore.instance
        .collection("Plants-ref")
        .doc(commonName)
        .get()
        .then((value) {
      return value.data()!['plantType'];
    });

    String waterNeeds = await FirebaseFirestore.instance
        .collection("Plants-ref")
        .doc(commonName)
        .get()
        .then((value) {
      return value.data()!['waterNeeds'];
    });
    final json = {
      "CommonName": commonName,
      "humidity": 0.toDouble(),
      "light_level": 0.toDouble(),
      "soil_moisture": 0.toDouble(),
      "temperature": 0.toDouble(),
      "location": location,
      "plantType": plantType,
      "waterNeeds": waterNeeds,
      "comfort_level": "Unknown",
    };

    await docUser.set(json);
  }

  plantsCounter({required String username}) async {
    AggregateQuerySnapshot query = await FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .collection("Plants")
        .count()
        .get();
    int numberOfDocuments = query.count;
    return numberOfDocuments;
  }
}

class BackendService {
  static Future<List> getSuggestions(String query) async {
    var snapshot =
        await FirebaseFirestore.instance.collection("Plants-ref").get();
    var idList = snapshot.docs.map((doc) => doc.id).toList();

    List<String> matches = [];
    matches.addAll(idList);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
