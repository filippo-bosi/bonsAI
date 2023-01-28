import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/route/routing_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/plants_list_screen.dart';

import '../auth_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: AuthHelper.initializeFirebase(context: context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          User? user = AuthHelper.currentUser();
          if (user != null) {
            Future.delayed(Duration.zero, () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlantsScreen(user: user.email!)));
            });
            print("EMAIL: " + user.email!);
          } else {
            return _getScreen(context);
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }

  _getScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        children: [
          Flexible(
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    height: 300,
                    child: Image(
                      image: AssetImage(
                        'assets/images/electricBonsai-circ.png',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "BonsAI",
                  style: kHeadline,
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "Welcome to BonsAI, your personal plant care assistant. Keep an eye on your plants' vital parameters and never forget to water them again with our convenient scheduling feature. Start taking care of your green friends today with BonsAI.",
                    style: kBodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.black12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context,
                        SignInScreenRoute, (Route<dynamic> route) => false);
                  },
                  child: Text(
                    'GET STARTED',
                    style: kButtonText.copyWith(color: Colors.white),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
