// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';

class VenueCard extends StatelessWidget {
  final String venueName;
  final String location;
  final double rating;
  final int price;
  final String imageUrl;
  final String priceType;
  final int ratingCount;
  final VoidCallback onTap;
  final String roomType;
  final String capacityType;

  const VenueCard({
    super.key,
    required this.venueName,
    required this.location,
    required this.rating,
    required this.ratingCount,
    required this.price,
    required this.imageUrl,
    required this.priceType,
    required this.onTap,
    required this.roomType,
    required this.capacityType,
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
                    imageUrl: imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ratingCount > 999
                              ? '(${(ratingCount / 1000).toStringAsFixed(1)}k)'
                              : '($ratingCount)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                          location,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CategoryChip(
                        label: roomType,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.8),
                        isBackground: true,
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: capacityType,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start from',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: priceType,
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
                                  .format(price), // Format harga
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
