import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';

class VenueRecommendCard extends StatelessWidget {
  final String imageUrl;
  final String venueName;
  final String location;
  final String capacity;
  final String price;
  final String rating;

  const VenueRecommendCard(
      {super.key,
      required this.imageUrl,
      required this.venueName,
      required this.location,
      required this.capacity,
      required this.price,
      required this.rating});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 200,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                child: NetworkImageWithLoader(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 90,
                )),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        rating,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start from',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  )),
                      Text(
                        price,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
