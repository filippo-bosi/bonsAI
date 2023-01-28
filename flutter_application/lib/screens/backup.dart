import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/const/custom_styles.dart';
import 'package:flutter_application/route/routing_constants.dart';
import 'package:flutter_application/screens/configureESP32.dart';
import 'package:flutter_application/screens/dashboard_screen.dart';
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
  static String collection1Name = 'Users';
  late String docName = widget.user;
  static String collection2Name = 'Plants';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 30),
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
                          Text(
                            "Plants List",
                            style: kHeadline,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Nice garden!",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 60,
                          ),
                          Expanded(
                            flex: 3,
                            child: TodosScreen(
                              todos: List.generate(
                                //await plantsCounter(username: docName),
                                3,
                                (i) => Todo(
                                  'Plant_$i',
                                  i,
                                ),
                              ),
                              user: docName,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyTextButton(
                      buttonName: 'Add new Plant',
                      onTap: () {
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context,
                        //     ConfigureScreenRoute,
                        //     (Route<dynamic> route) => false);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ConfigureScreen(user: docName)));
                      },
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    SizedBox(
                      height: 40,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<int> plantsCounter({required String username}) async {
    AggregateQuerySnapshot query = await FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .collection("Plants")
        .count()
        .get();
    int numberOfDocuments = query.count;
    print(numberOfDocuments);
    return numberOfDocuments;
  }

  _signOut() async {
    await AuthHelper.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, SplashScreenRoute, (Route<dynamic> route) => false);
  }
}

class TodosScreen extends StatelessWidget {
  const TodosScreen({Key? key, required this.todos, required this.user})
      : super(key: key);
  final String user;
  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              todos[index].title,
              style: kButtonText2,
            ),
            // When a user taps the ListTile, navigate to the DetailScreen.
            // Notice that you're not only creating a DetailScreen, you're
            // also passing the current todo through to it.
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         DashboardScreen(user: user, todo: todos[index]),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}

class Todo {
  final String title;
  final int index;
  const Todo(this.title, this.index);
}


 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//             child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(weather.current),
//         Text(weather.temperature.toString()),
//         GestureDetector(
//           onTap: () {
//             Navigator.pushNamed(context, PlantScreenRoute);
//           },
//           child: Text(
//             'Register',
//             style: kBodyText.copyWith(
//               color: Colors.white,
//             ),
//           ),
//         )
//       ],
//     )));
//   }
// }
