import 'package:maoyi/pages/home/home_page.dart';
import 'package:maoyi/pages/login/login_page.dart';

import 'routes.dart' as routes;

import 'package:flutter/material.dart';

Route<dynamic> router(BuildContext context, RouteSettings settings) {
  var path = settings.name;

  Widget page;
  switch (path) {
    case routes.Home:
      page = HomePage();
      break;

    case routes.UserInfo:
      break;
    case routes.UserNew:
      break;
    case routes.RouteAuthLogin:
      page = LoginPage();
      break;

    default:
      break;
  }

  return MaterialPageRoute(builder: (context) => page);
}
