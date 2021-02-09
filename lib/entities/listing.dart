import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:***REMOVED***/entities/commodity.dart';
import 'package:***REMOVED***/entities/user.dart';
import 'package:map_launcher/map_launcher.dart';

part 'listing.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Listing {
  num id;
  String dateCreated; // todo: finn ut hvilket dato format vi ender med
  User creator;
  String endDate;
  Commodity commodity;
  int price;
  bool isOpen;

  Listing(
      {@required this.id,
      this.dateCreated,
      this.creator,
      this.endDate,
      this.commodity,
      this.price,
      this.isOpen});

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
  Map<String, dynamic> toJson() => _$ListingToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OfferListing extends Listing {
  int maxAmount;
  int amountLeft;
  //Coordinates for pickup.
  Coords coords;

  OfferListing(
      {@required num id,
      String dateCreated,
      User creator,
      String endDate,
      Commodity commodity,
      int price,
      bool isOpen,
      @required this.maxAmount,
      @required this.amountLeft,
      this.coords})
      : super(
            id: id,
            dateCreated: dateCreated,
            creator: creator,
            endDate: endDate,
            commodity: commodity,
            price: price,
            isOpen: isOpen);

  double getDistanceTo() {
    return 3;
  }

  factory OfferListing.fromJson(Map<String, dynamic> json) =>
      _$OfferListingFromJson(json);
  Map<String, dynamic> toJson() => _$OfferListingToJson(this);
}
