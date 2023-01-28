import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/route/routing_constants.dart';
import 'package:flutter_application/screens/configureESP32.dart';
import 'package:flutter_application/screens/dashboard_screen.dart';
import 'package:flutter_application/widgets/my_plant_card.dart';
import 'package:flutter_application/widgets/my_text_button.dart';
import 'package:flutter_application/auth_helper.dart';
import 'package:flutter/material.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({Key? key, required this.user}) : super(key: key);
  final String user;

  @override
  _PlantsScreenState createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<String> assets = [
    'assets/images/plant0.png',
    'assets/images/plant1.png',
    'assets/images/plant2.png',
    'assets/images/plant3.jpg',
    'assets/images/plant4.png',
    'assets/images/plant5.png',
    'assets/images/plant6.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.user)
          .collection("Plants")
          .snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.requireData;

        return Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 30),
          child: CustomScrollView(reverse: true, slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plants List',
                            style: kHeadline,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 500,
                                  child: ListView.builder(
                                      itemCount: data.size,
                                      itemBuilder: (context, index) {
                                        final item = data.docs[index];
                                        return Dismissible(
                                            key: UniqueKey(),
                                            //Key(data.docs[index].id),
                                            direction:
                                                DismissDirection.endToStart,
                                            onDismissed: (direction) {
                                              // Remove the item from the data source.
                                              setState(() {
                                                final collection =
                                                    FirebaseFirestore.instance
                                                        .collection('Users')
                                                        .doc(widget.user)
                                                        .collection("Plants");
                                                collection
                                                    .doc(data.docs[index].id)
                                                    .delete()
                                                    .then(
                                                        (_) => print('Deleted'))
                                                    .catchError((error) => print(
                                                        'Delete failed: $error'));
                                                // data.docs.removeAt(index);
                                              });

                                              // Then show a snackbar.
                                              final index2 = index + 1;

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Plant_$index2 deleted')));
                                            },
                                            background: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.trash_fill,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Delete',
                                                      style: kBodyText3,
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              color: Colors.red,
                                            ),
                                            // child: ListTile(
                                            //   title: Text(
                                            //     data.docs[index].id,
                                            //     style: kBodyText2,
                                            //   ),
                                            child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DashboardScreen(
                                                                user:
                                                                    widget.user,
                                                                index: index),
                                                      ),
                                                    ),
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      MyPlantCard(
                                                        commonName:
                                                            "Plant_${index + 1}",
                                                        type: "Herb",
                                                        waterNeeds:
                                                            "400 to 600mm",
                                                        assetImage: AssetImage(
                                                            assets[index]),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      )
                                                    ],
                                                  ),
                                                )));
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MyTextButton(
                      buttonName: 'Add new Plant',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ConfigureScreen(user: widget.user)));
                      },
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign out of BonsAI? ",
                          style: kBodyText,
                        ),
                        GestureDetector(
                          onTap: _signOut,
                          child: Text(
                            "Sign Out",
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
            )
          ]),
        );
      },
    ));
  }

  _signOut() async {
    await AuthHelper.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, SplashScreenRoute, (Route<dynamic> route) => false);
  }
}
