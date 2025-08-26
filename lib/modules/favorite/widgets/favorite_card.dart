import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/favorite/models/favorite_model.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;

  const FavoriteCard({
    super.key,
    required this.favorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        MyRoutes.venueDetail,
        arguments: {'venueId': favorite.venue.id},
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  NetworkImageWithLoader(
                    imageUrl: favorite.venue.firstPictureUrl ?? '',
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                  // Rating badge (if available)
                  if (favorite.venue.rating != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              favorite.venue.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Favorite heart icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Venue name
                    Text(
                      favorite.venue.name ?? 'Unnamed Venue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            favorite.venue.address ?? 'No address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom row with price and capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        if (favorite.venue.price != null)
                          Text(
                            "IDR ${NumberFormat("#,##0", "id_ID").format(favorite.venue.price!)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32), // Consistent green color
                            ),
                          ),
                        // Capacity
                        if (favorite.venue.maxCapacity != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withOpacity(0.1), // Consistent blue
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 12,
                                  color: Color(0xFF1976D2), // Consistent blue
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${favorite.venue.maxCapacity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2), // Consistent blue
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
            ),
          ],
        ),
      ),
    );
  }
}