import 'package:flutter_application/route/routing_constants.dart';
import 'package:flutter_application/screens/signin_screen.dart';
import 'package:flutter_application/screens/signup_screen.dart';
import 'package:flutter_application/screens/splash_screen.dart';
import 'package:flutter_application/screens/undefined_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreenRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());

    case SignInScreenRoute:
      return MaterialPageRoute(builder: (context) => SignInScreen());

    case SignUpScreenRoute:
      return MaterialPageRoute(builder: (context) => SignUpScreen());

    //case PlantsScreenRoute:
    //return MaterialPageRoute(builder: (context) => PlantsScreen());

    // case ConfigureScreenRoute:
    //   return MaterialPageRoute(builder: (context) => ConfigureScreen());

    // case AddNewPlantScreenRoute:
    //   return MaterialPageRoute(builder: (context) => AddNewPlantScreen());

    // case DashboardScreenRoute:
    //   return MaterialPageRoute(builder: (context) => DashboardScreen());

    default:
      return MaterialPageRoute(
          builder: (context) => UndefinedView(
                name: settings.name!,
              ));
  }
}
