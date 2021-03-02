import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fishapp/entities/listing.dart';
import 'package:fishapp/widgets/distance_to_widget.dart';
import 'package:fishapp/widgets/rating_stars.dart';
import 'package:fishapp/generated/l10n.dart';

import 'rating_stars.dart';

class OfferListingCard extends StatelessWidget {
  final OfferListing cardListing;

  const OfferListingCard({Key key, this.cardListing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          Text(
            cardListing.creator.name,
            style: Theme.of(context).primaryTextTheme.headline5,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserRatingStars(user: cardListing.creator),
                  DistanceToWidget(cardListing: cardListing),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).price,
                    style: Theme.of(context).primaryTextTheme.headline5,
                  ),
                  Text(
                    S.of(context).availability,
                    style: Theme.of(context).primaryTextTheme.headline6,
                  )
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardListing.price.toString() + "kr/Kg",
                    style: Theme.of(context).primaryTextTheme.headline5,
                  ),
                  Text(
                    cardListing.amountLeft.toString() + "Kg",
                    style: Theme.of(context).primaryTextTheme.headline6,
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
