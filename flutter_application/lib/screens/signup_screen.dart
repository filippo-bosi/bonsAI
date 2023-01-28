import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/auth_helper.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/route/routing_constants.dart';
import 'package:flutter_application/screens/plants_list_screen.dart';
import 'package:flutter_application/widgets/my_password_field.dart';
import 'package:flutter_application/widgets/my_text_button.dart';
import 'package:flutter_application/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passwordVisibility = true;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Flexible(
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
                            "Register",
                            style: kHeadline,
                          ),
                          Text(
                            "Create new account to get started.",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          MyTextField(
                            hintText: 'Email',
                            inputType: TextInputType.emailAddress,
                            textEditingController: _email,
                          ),
                          MyPasswordField(
                            hintText: 'Password',
                            textEditingController: _password,
                            isPasswordVisible: passwordVisibility,
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                          ),
                          MyPasswordField(
                            hintText: 'Password Confirm',
                            textEditingController: _passwordConfirm,
                            isPasswordVisible: passwordVisibility,
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: kBodyText,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                SignInScreenRoute,
                                (Route<dynamic> route) => false);
                          },
                          child: Text(
                            "Sign In",
                            style: kBodyText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyTextButton(
                      buttonName: 'Register',
                      onTap: _signUp,
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _signUp() async {
    var email = _email.text.trim();
    var pw = _password.text.trim();
    var pwConfirm = _passwordConfirm.text.trim();

    if (email.isEmpty || pw.isEmpty || pw != pwConfirm) {
      if (email.isEmpty || pw.isEmpty) {
        await showOkAlertDialog(
          context: context,
          message: 'Check your email or password',
        );
      } else if (pw != pwConfirm) {
        await showOkAlertDialog(
          context: context,
          message: 'Passwords do not match',
        );
      }
      return;
    }

    var obj = await AuthHelper.signUp(email, pw);

    if (obj is User) {
      addUserFirestore(username: email, password: pw);

      // Navigator.pushNamedAndRemoveUntil(
      //     context,
      //     PlantsScreenRoute,
      //     (Route<dynamic> route) => false,
      //     arguments:,
      // );
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PlantsScreen(user: email)));
    } else {
      await showOkAlertDialog(
        context: context,
        message: obj,
      );
    }
  }

  Future addUserFirestore(
      {required String username, required String password}) async {
    final docUser =
        FirebaseFirestore.instance.collection("Users").doc(username);
    final json = {
      "email": username,
      "password": password,
    };
    await docUser.set(json);
  }
}

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}
