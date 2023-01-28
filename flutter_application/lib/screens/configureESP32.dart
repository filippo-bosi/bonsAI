import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/screens/new_plant_screen.dart';
import 'package:flutter_application/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';

class ConfigureScreen extends StatefulWidget {
  const ConfigureScreen({Key? key, required this.user}) : super(key: key);
  final String user;

  @override
  _ConfigureScreenState createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 30),
        child: CustomScrollView(
          reverse: true,
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
                            "Add a new Plant",
                            style: kHeadline,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Configure ESP32!",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 130,
                            child: Image(
                              image: AssetImage(
                                'assets/images/esp32devkit-esp32-gif.gif',
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              "To begin, connect your ESP32 to a power source and open the Wi-Fi settings by clicking the button below. Then, connect to the BonsAI network and follow the prompts to configure an access point for your ESP32.\n\nOnce you are done with that, come back to this page and press 'Next'.",
                              style: kBodyText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          MyTextButton(
                            buttonName: 'Wi-Fi Settings',
                            onTap: () {
                              OpenSettings.openWIFISetting();
                            },
                            bgColor: Colors.white,
                            textColor: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Done? ",
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddNewPlantScreen(user: widget.user)));
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
}
