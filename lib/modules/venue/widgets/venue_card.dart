// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/favorite_button.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

class VenueCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback onTap;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: NetworkImageWithLoader(
                    imageUrl: venue.firstPictureUrl ?? '',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteButton(isFavorite: false, onTap: onTap)),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name ?? "No Information",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rating row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (venue.rating ?? 0.0)
                                .toString(), // Using venue.rating with proper type conversion
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (venue.ratingCount ?? 0) > 999
                                ? '(${(venue.ratingCount! / 1000).toStringAsFixed(1)}k)'
                                : '(${venue.ratingCount ?? 'No Review'})',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 18,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          venue.address ?? "Unknown Location",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  //Category
                  Row(
                    children: [
                      CategoryChip(
                        label: venue.category?.name ?? "No Category",
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.8),
                        isBackground: true,
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: venue.maxCapacity.toString(),
                        icon: Icons.groups_2,
                        isBackground: true,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  //Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Start From
                      Text(
                        'Start from',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      //Format Price
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Rp.",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextSpan(
                              text: NumberFormat("#,##0", "id_ID")
                                  .format(venue.price ?? 0), // Format harga
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
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
