import 'package:flutter/material.dart';
import 'package:flutter_application/const/custom_colors.dart';
import 'package:flutter_application/const/custom_styles.dart';

class MyPlantCard extends StatelessWidget {
  const MyPlantCard({
    Key? key,
    required this.commonName,
    required this.type,
    required this.waterNeeds,
    required this.assetImage,
  }) : super(key: key);

  final String commonName;
  final String type;
  final String waterNeeds;
  final AssetImage assetImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: Colors.white,
      elevation: 24,
      color: kMainBG,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
        child: Row(children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  width: 80,
                  image: assetImage,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(commonName,
                    style: kBodyText.copyWith(color: Colors.white)),
                SizedBox(
                  height: 10,
                ),
                Text(type, style: kBodyText.copyWith(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    width: 110,
                    image: AssetImage('assets/images/water-level.png'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(waterNeeds,
                      style: kBodyText.copyWith(color: Colors.white)),
                ],
              )),
        ]),
      ),
    );
  }
}
