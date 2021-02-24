import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:maoyi/constants/api_path.dart' as apiPaths;
import 'package:maoyi/entities/commodity.dart';
import 'package:maoyi/entities/listing.dart';
import 'package:maoyi/pages/listing/listing_formdata.dart';
import 'package:maoyi/utils/services/maoyi_rest_client.dart';


class CommodityService {
  final MaoyiRestClient _client = MaoyiRestClient();

  Future<Commodity> getCommodity(BuildContext context, num id) async {
    var response = await _client.get(context, apiPaths.getCommodity);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      if (body["data"] != null) {
        return Commodity.fromJson(body["data"]);
      }
    }
    return null;
  }

  Future<List<Commodity>> getAllCommodities(BuildContext context) async {
    var response = await _client.get(context, apiPaths.getAllCommodity, addAuth: true);
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

class ListingService {
  final MaoyiRestClient _client = MaoyiRestClient();

  Future<Listing> getCommodity(BuildContext context, num id) async {
    var response = await _client.get(context, apiPaths.getListing);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      if (body["data"] != null) {
        return Listing.fromJson(body["data"]);
      }
    }
    return null;
  }
  
  Future<OfferListing> createOfferListing(
      BuildContext context, ListingFormData details) async {
    OfferListing offerListing;
    try {
      var response = await _client.post(context, apiPaths.createOfferListing,
      headers: details.toMap(), addAuth: true);
      switch (response.statusCode) {
        case 200:
         return offerListing = OfferListing.fromJson(jsonDecode(response.body));
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
}
