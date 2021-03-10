import 'package:fishapp/entities/chat/conversation.dart';
import 'package:fishapp/entities/receipt.dart';
import 'package:fishapp/pages/chat/chatlist_page.dart';
import 'package:fishapp/pages/chat/chatmsg_page.dart';
import 'package:fishapp/pages/home/home_page.dart';
import 'package:fishapp/pages/listing/buy_request_info_page.dart';
import 'package:fishapp/pages/listing/choose_new_listing_page.dart';
import 'package:fishapp/pages/listing/listing_info_page.dart';
import 'package:fishapp/pages/listing/new_buy_request_page.dart';
import 'package:fishapp/pages/listing/new_offer_listing_page.dart';
import 'package:fishapp/pages/login/login_page.dart';
import 'package:fishapp/pages/receipt/receipt_page.dart';
import 'package:fishapp/pages/register/register_seller_page.dart';
import 'package:fishapp/pages/register/register_user_page.dart';
import 'package:fishapp/pages/user/user_info.dart';
import 'package:fishapp/pages/user/user_resetpwd_page.dart';
import 'package:fishapp/utils/state/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/listing.dart';
import 'route_data.dart';
import 'routes.dart' as routes;

Route<dynamic> router(BuildContext context, RouteSettings settings) {
  var path = settings.name;
  var params = settings.arguments;

  Widget page;

  bool loggedIn = Provider.of<AppState>(context).isLoggedIn();
  bool isSeller = Provider.of<AppState>(context).isSeller();

  Function reqireLogin = (Function route) {
    if (loggedIn) {
      return route();
    } else {
      return LoginPage(
          loginReturnRouteData: LoginReturnRouteData(path, params));
    }
  };

  switch (path) {
    case routes.Home:
      page = HomePage();
      break;

    case routes.UserNew:
      page = RegisterUserPage(
        returnRouteData: params,
      );
      break;
    case routes.UserLogin:
      page = LoginPage(
        loginReturnRouteData: params,
      );
      break;
    case routes.OfferListingInfo:
      if (params is OfferListing) {
        print(params.toJsonString());
        page = OfferListingInfoPage(
          offerListing: params,
        );
      } else {
        page = Path404Page();
      }
      break;
    case routes.BuyRequestInfo:
      if (params is BuyRequest) {
        page = BuyRequestInfoPage(
          buyRequest: params,
        );
      } else {
        page = Path404Page();
      }
      break;
    case routes.ChooseNewListing:
      if (isSeller) {
        page = ChooseNewListingPage();
      } else {
        page = reqireLogin(() {
          return NewBuyRequestPage(
            routeData: params,
          );
        });
      }
      break;
    case routes.SellerNew:
      page = RegisterSellerPage(
        returnRouteData: params,
      );
      break;

    ///  --  Needs login below  -- ///

    case routes.receiptsList:
      page = reqireLogin(() {
        return ReceiptListPage();
      });
      break;
    case routes.receipt:
      if (params is Receipt) {
        page = reqireLogin(() {
          return ReceiptPage(
            receipt: params,
          );
        });
      } else {
        page = Path404Page();
      }
      break;
    case routes.UserInfo:
      page = reqireLogin(() {
        return UserPage();
      });
      break;
    case routes.UserResetPwd:
      page = reqireLogin(() {
        return ChangePasswordPage();
      });
      break;
    case routes.chat:
      page = reqireLogin(() {
        return ChatListPage();
      });
      break;
    case routes.ChatConversation:
      if (params is Conversation) {
        page = reqireLogin(() {
          return ChatMessagePage(
            baseConversation: params,
          );
        });
      } else {
        page = Path404Page();
      }
      break;
    case routes.NewListing:
      page = reqireLogin(() {
        return NewOfferListingPage(
          routeData: params,
        );
      });
      break;
    case routes.NewBuyRequest:
      page = reqireLogin(() {
        return NewBuyRequestPage(
          routeData: params,
        );
      });
      break;

    default:
      page = Path404Page();
      break;
  }

  return MaterialPageRoute(builder: (context) => page);
  //return FadeRoute(page: page);
}

class Path404Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("ERROR SIDE NOT FOUND"
          "/side note burde kansje ha en vei ut av skjermen her"),
    );
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class ScaleRotateRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRotateRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: Duration(seconds: 1),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: RotationTransition(
              turns: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.linear,
                ),
              ),
              child: child,
            ),
          ),
        );
}
