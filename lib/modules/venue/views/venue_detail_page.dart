import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/about_detail.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/contact_host_widget.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/facilities_section.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/image_gallery.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueDetailController controller = Get.find<VenueDetailController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: _buildVenueDetailContent(context, controller),
          );
        } else if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                PrimaryButton(
                    isLoading: false,
                    text:
                        LocalizationHelper.tr(LocaleKeys.common_retry), // FIXED
                    onPressed: controller.retryLoading),
              ],
            ),
          );
        } else {
          return _buildVenueDetailContent(context, controller);
        }
      }),
    );
  }

  Widget _buildVenueDetailContent(
      BuildContext context, VenueDetailController controller) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: controller.refreshVenueDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    // Single Main Image
                    Skeleton.ignore(
                      child: SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Obx(() {
                          // Cek gambar utama
                          String? imageUrl =
                              controller.venue.value?.firstPictureUrl;
                          // Jika null/kosong, fallback ke venueImages
                          if (imageUrl == null || imageUrl.isEmpty) {
                            if (controller.venueImages.isNotEmpty) {
                              imageUrl = controller.venueImages.first.imageUrl;
                            }
                          }
                          return GestureDetector(
                            onTap: () {
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                controller.openImageAtIndex(context, 0);
                              }
                            },
                            child: NetworkImageWithLoader(
                              imageUrl: imageUrl ?? "",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            ),
                          );
                        }),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 40,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Get.back(result: true),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 150),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        children: [
                          ImageGallery(
                            images: controller.venueImages,
                            onImageTap: (index) {
                              controller.openImageAtIndex(context, index);
                            },
                          ),
                          _buildVenueInfoSection(context, controller),
                          _buildLocationSection(context, controller),
                          FacilitiesSection(),
                          _buildReviewsSection(context, controller),
                          // _buildScheduleSection(context, controller),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildPriceAndBooking(context, controller),
        ),
      ],
    );
  }

  // Section 1
  Widget _buildVenueInfoSection(
      BuildContext context, VenueDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.venue.value?.name ??
                            LocalizationHelper.tr(LocaleKeys.common_noData),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating section with new API data
                      Obx(() {
                        if (controller.isLoadingRatingStats.value) {
                          return Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(LocalizationHelper.tr(LocaleKeys.labels_loadingRating)),
                            ],
                          );
                        }

                        final stats = controller.ratingStats.value;
                        if (stats == null || stats.totalReviews == 0) {
                          return Row(
                            children: [
                              const Icon(Icons.star_border,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                LocalizationHelper.tr(LocaleKeys.labels_noReviewsYet),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            // Star rating display
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < stats.averageRating.floor()
                                      ? Icons.star
                                      : index < stats.averageRating
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${stats.averageRating.toStringAsFixed(1)} (${stats.totalReviews} ${stats.totalReviews == 1 ? 'review' : 'reviews'})',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Obx(() {
                      return IconButton(
                        icon: Icon(
                          controller.isFavorite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22,
                          color:
                              controller.isFavorite.value ? Colors.red : null,
                        ),
                        onPressed: () => controller.toggleFavorite(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Categories and Capacity
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Capacity chip
                CategoryChip(
                  label:
                      '1-${controller.venue.value?.maxCapacity ?? LocalizationHelper.tr(LocaleKeys.venue_capacity_unknown)}',
                  color: Colors.blue,
                  icon: Icons.groups_2,
                ),

                // Area chip
                CategoryChip(
                  label:
                      controller.venue.value?.size ?? LocalizationHelper.tr(LocaleKeys.labels_sizeNotAvailable),
                  color: Colors.blue,
                  icon: Icons.straighten,
                ),
              ],
            ),
          ),

          // Activities - Container terpisah
          if (controller.activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationHelper.tr(LocaleKeys.labels_activities),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.activities
                        .map((activity) => CategoryChip(
                              label: activity.name ?? LocalizationHelper.tr(LocaleKeys.labels_unknownActivity),
                              color: Colors.green,
                              icon: Icons.local_activity,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // About
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocalizationHelper.tr(LocaleKeys.venue_aboutVenue),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomTextButton(
                    text: LocalizationHelper.tr(LocaleKeys.common_showMore),
                    onTap: () {
                      Get.to(() => AboutDetail(
                          venueName: controller.venue.value?.name ??
                              LocalizationHelper.tr(LocaleKeys.venue_details),
                          venueDescription:
                              controller.venue.value?.description ?? ''));
                    },
                    icon: Icons.arrow_forward,
                    isrightIcon: true,
                  ),
                ],
              ),
              Text(
                controller.venue.value?.description ??
                    LocalizationHelper.tr(LocaleKeys.venue_description_default),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Venue Owner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      radius: 20,
                      child: Text(
                        (controller.venue.value?.host?.displayName.isNotEmpty ??
                                false)
                            ? controller.venue.value!.host!.displayName[0]
                                .toUpperCase()
                            : 'H',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationHelper.tr(LocaleKeys.labels_host),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          controller.venue.value?.host?.displayName ??
                              LocalizationHelper.tr(
                                  LocaleKeys.venue_owner_defaultName),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() {
                  final venue = controller.venue.value;

                  return venue != null
                      ? ContactHostWidget(
                          venue: venue,
                          style: ContactHostStyle.button,
                          customText: LocalizationHelper.tr(LocaleKeys.buttons_contact),
                        )
                      : const SizedBox(
                          width: 80,
                          height: 42,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 2
  Widget _buildLocationSection(
      BuildContext context, VenueDetailController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () async {
          // Ambil venue dari controller
          final venue = controller.venue.value;

          if (venue?.address != null) {
            // Encode alamat untuk URL
            final encodedAddress = Uri.encodeComponent(venue!.address!);
            final googleMapsUrl =
                'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

            final uri = Uri.parse(googleMapsUrl);

            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // Show error jika gagal
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocalizationHelper.tr(LocaleKeys.messages_couldNotOpenMaps))),
                  );
                }
              }
            } catch (e) {
              // Handle error
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LocalizationHelper.trArgs(LocaleKeys.messages_errorOccurred, {'error': e.toString()}))),
                );
              }
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.venue.value?.address ??
                          LocalizationHelper.tr(
                              LocaleKeys.venue_noLocationData),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () async {
                  // Sama dengan GestureDetector onTap di atas
                  final venue = controller.venue.value;

                  if (venue?.address != null) {
                    final encodedAddress = Uri.encodeComponent(venue!.address!);
                    final googleMapsUrl =
                        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

                    final uri = Uri.parse(googleMapsUrl);

                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      print('Error launching maps: $e');
                    }
                  }
                },
                icon: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Section 4
  // // Widget _buildScheduleSection(
  // //     BuildContext context, VenueDetailController controller) {
  // //   return Container(
  // //     margin: const EdgeInsets.only(top: 16),
  // //     padding: const EdgeInsets.all(16),
  // //     decoration: BoxDecoration(
  // //       color: Colors.white,
  // //       borderRadius: BorderRadius.circular(8),
  // //       border: Border.all(color: Colors.grey[300]!),
  // //     ),
  // //     child: Column(
  // //       crossAxisAlignment: CrossAxisAlignment.start,
  // //       children: [
  // //         Row(
  // //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // //           children: [
  // //             Text(
  // //               LocalizationHelper.tr(LocaleKeys.venue_schedule),
  // //               style: const TextStyle(
  // //                 color: Colors.black,
  // //                 fontSize: 16,
  // //                 fontWeight: FontWeight.bold,
  // //               ),
  // //             ),
  // //             CustomTextButton(
  // //               text: LocalizationHelper.tr(LocaleKeys.common_showMore),
  // //               onTap: () {},
  // //               icon: Icons.arrow_forward,
  // //               isrightIcon: true,
  // //             ),
  // //           ],
  // //         ),
  // //         Column(
  // //           children: [
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_monday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_tuesday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_wednesday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_thursday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_friday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_saturday),
  // //                 '7:00 - 21:00'),
  // //             _buildScheduleItem(
  // //                 LocalizationHelper.tr(LocaleKeys.common_sunday),
  // //                 LocalizationHelper.tr(LocaleKeys.venue_closed)),
  // //           ],
  // //         ),
  // //       ],
  // //     ),
  // //   );
  // // }

  // // Widget _buildScheduleItem(String day, String time) {
  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     margin: const EdgeInsets.only(top: 8),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey[300]!),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           day,
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),
  //         Text(
  //           time,
  //           style: TextStyle(fontSize: 12, color: Colors.grey[700]),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Float Section
  Widget _buildPriceAndBooking(
    BuildContext context,
    VenueDetailController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationHelper.tr(LocaleKeys.venue_startFrom),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "IDR ${NumberFormat("#,##0", "id_ID").format(controller.venue.value?.price ?? 100000)}",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          LocalizationHelper.tr(LocaleKeys.venue_perHour),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Text(
                      LocalizationHelper.tr(LocaleKeys.venue_includeTax),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SecondaryButton(
                  text: LocalizationHelper.tr(LocaleKeys.booking_bookNow),
                  onPressed: () {
                    final venue = controller.venue.value;
                    if (venue != null) {
                      Get.toNamed(
                        MyRoutes.bookingPage,
                        arguments: venue,
                      );
                    } else {
                      CustomSnackbar.show(
                        context: context,
                        message: LocalizationHelper.tr(
                            LocaleKeys.errors_venueUnavailable),
                        type: SnackbarType.error,
                        autoClear: true,
                        enableDebounce: false
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(
      BuildContext context, VenueDetailController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationHelper.tr(LocaleKeys.pages_reviewsPage),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextButton(
                text: LocalizationHelper.tr(LocaleKeys.buttons_showAll),
                onTap: () {
                  Get.toNamed(
                    MyRoutes.reviewPage,
                    arguments: {'venueId': controller.venue.value?.id},
                  );
                },
                icon: Icons.arrow_forward,
                isrightIcon: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingReviews.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (controller.reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  LocalizationHelper.tr('labels.noReviewsYet'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            } else {
              // Limit to 2 reviews but don't create a sublist (avoid unnecessary copying)
              final reviewCount =
                  controller.reviews.length > 2 ? 2 : controller.reviews.length;

              return Column(
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviewCount,
                      itemBuilder: (context, index) {
                        final review = controller.reviews[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    radius: 16,
                                    child: Text(
                                      review.username.isNotEmpty
                                          ? review.username[0].toUpperCase()
                                          : 'U',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(review.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (review.rating)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: index < (review.rating)
                                            ? Colors.amber
                                            : Colors.grey,
                                        size: 14,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review.comment ?? '',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }),
                  if (controller.reviews.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed(
                            MyRoutes.reviewPage,
                            arguments: {'venueId': controller.venue.value?.id},
                          );
                        },
                        child: Text(
                          LocalizationHelper.trArgs(LocaleKeys.labels_viewAllReviews, {'count': controller.reviews.length.toString()}),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}
