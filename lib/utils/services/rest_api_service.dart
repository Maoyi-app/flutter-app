import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:fishapp/entities/chat/conversation.dart';
import 'package:fishapp/entities/chat/message.dart';
import 'package:fishapp/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:fishapp/constants/api_path.dart' as apiPaths;
import 'package:fishapp/entities/commodity.dart';
import 'package:fishapp/entities/listing.dart';
import 'package:fishapp/utils/services/fishapp_rest_client.dart';

import '../../constants/api_path.dart';
import '../../entities/listing.dart';
import '../../entities/listing.dart';
import '../../entities/listing.dart';
import '../../entities/listing.dart';
import '../../entities/listing.dart';
import '../../entities/listing.dart';

class ConversationService {
  final FishappRestClient _client = FishappRestClient();

  Future<List<Conversation>> getAllConversations(BuildContext context) async {
    List<Conversation> conversations = List();
    conversations.add(testConversation);
    conversations.add(testConversation2);
    return conversations;
  }

  Future<List<Message>> getAllMessagesInConversation(BuildContext context, num conversationId) async {
    List<Message> messages = List();
    //FIXME: testing alot of messages
    for(int i = 0; i < 30; i++) {
      Message m = Message();
      m.id = i+1;
      int j = i % 2;
      if (j == 0) {
        m.senderId = 23;
        m.content = "masse fisk!";
      } else {
        m.senderId = 1;
        m.content = "kjøpe kjøpe kjøpe!";
      }
      messages.add(m);
      //print("Got message with sender " + m.senderId.toString());
    }
    print("API: Got " + messages.length.toString() + "messages!");
    return messages;
  }

  Future<Conversation> startNewConversation(BuildContext context,
      num listingId) async {
    Conversation c = Conversation();
    c.id = testConversation.id++;
    c.listing = testOfferListing;
    c.firstMessageId = 0;
    c.lastMessageId = 0;
  }
}



class CommodityService {
  final FishappRestClient _client = FishappRestClient();

  Future<Commodity> getCommodity(BuildContext context, num id) async {
    var uri = getAppUri(apiPaths.getCommodity);
    var response = await _client.get(context, uri, addAuth: false);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      if (body["data"] != null) {
        return Commodity.fromJson(body["data"]);
      }
    }
    return null;
  }

  Future<List<Commodity>> getAllCommodities(BuildContext context) async {
    var uri = getAppUri(apiPaths.getAllCommodity);
    var response = await _client.get(context, uri, addAuth: false);
    List returnList;

    switch (response.statusCode) {
      case 200:
        var body = jsonDecode(response.body);
        returnList = Commodity.fromJsonList(body);
        break;
      case 401:
        throw HttpException(HttpStatus.unauthorized.toString());
        break;
      case 500:
        throw HttpException(HttpStatus.internalServerError.toString());
        break;
      default:
        returnList = List();
        break;
    }
    return returnList;
  }
}

class RatingService {
  final FishappRestClient _client = FishappRestClient();

  Future<num> getRating(BuildContext context, num id) async {
    var uri = getAppUri(apiPaths.ratingEndpoint + id.toString());
    var response = await _client.get(context, uri);

    if (response.statusCode == 200) {
      return num.parse(response.body);
    }
    return null;
  }
}

class ListingService {
  final FishappRestClient _client = FishappRestClient();

  Future<OfferListing> getOfferListing(BuildContext context, num id) async {
    var uri = getAppUri(apiPaths.getListing + id.toString());
    var response = await _client.get(context, uri, addAuth: false);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      if (body["data"] != null) {
        return OfferListing.fromJson(body["data"]);
      }
    }
    return null;
  }

  Future<List<OfferListing>> getCommodityOfferListing(
      BuildContext context, num id) async {
    var uri = getAppUri(apiPaths.getComodityListings + id.toString());
    var response = await _client.get(context, uri, addAuth: false);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      List<OfferListing> offerListings = List();
      for (var offerListing in body) {
        offerListings.add(OfferListing.fromJson(offerListing));
      }
      return offerListings;
    }
    return null;
  }

  Future<OfferListing> createOfferListing(
      BuildContext context, OfferListing offerListing) async {
    var uri = getAppUri(apiPaths.createOfferListing);
    try {
      var response = await _client.post(context, uri,
          headers: {'Content-type': "application/json"},
          body: offerListing.toJsonString(),
          addAuth: true);
      switch (response.statusCode) {
        case 200:
          return offerListing =
              OfferListing.fromJson(jsonDecode(response.body));
          break;
        case 401:
          throw HttpException(HttpStatus.unauthorized.toString());
          break;
        case 403:
          throw HttpException(HttpStatus.forbidden.toString());
          break;
        case 409:
          break;
        case 500:
        default:
          throw HttpException(HttpStatus.internalServerError.toString());
          break;
      }
    } on IOException catch (e) {
      log("IO failure " + e.toString(), time: DateTime.now());
      throw HttpException("Service unavailable");
    }
    return offerListing;
  }
  
  Future<BuyRequest> createBuyRequest(
      BuildContext context, BuyRequest buyRequest) async {
    var uri = apiPaths.getAppUri(apiPaths.createBuyRequest);
    try {
      var response = await _client.post(context, uri,
          headers: {'Content-type': "application/json"},
          body: buyRequest.toJsonString(),
          addAuth: true);
      switch (response.statusCode) {
        case 200:
          return buyRequest =
              BuyRequest.fromJson(jsonDecode(response.body));
          break;
        case 401:
          throw HttpException(HttpStatus.unauthorized.toString());
          break;
        case 403:
          throw HttpException(HttpStatus.forbidden.toString());
          break;
        case 409:
          break;
        case 500:
        default:
          throw HttpException(HttpStatus.internalServerError.toString());
          break;
      }
    } on IOException catch (e) {
      log("IO failure " + e.toString(), time: DateTime.now());
      throw HttpException("Service unavailable");
    }
    return buyRequest;
  }
}
