import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/services/whatsapp_contact_service.dart';
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
        SingleChildScrollView(
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                        _buildFacilitiesSection(context, controller),
                        _buildReviewsSection(context, controller),
                        _buildScheduleSection(context, controller),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Padding(
            padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(
                            ' ${controller.venue.value?.rating?.toStringAsFixed(1) ?? '0'} (${controller.venue.value?.ratingCount ?? '0'} ${LocalizationHelper.tr(LocaleKeys.venue_reviews)})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Icon(Icons.arrow_forward,
                              color: Colors.grey, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 22),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
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
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Category chip
                // CategoryChip(
                //   label: controller.venue.value?.category?.name ??
                //       LocalizationHelper.tr(
                //           LocaleKeys.venue_category_uncategorized),
                //   color: Colors.blue,
                // ),

                // Capacity chip
                CategoryChip(
                  label:
                      '1-${controller.venue.value?.maxCapacity ?? LocalizationHelper.tr(LocaleKeys.venue_capacity_unknown)}',
                  color: Colors.blue,
                  icon: Icons.groups_2,
                ),

                // Area chip
                CategoryChip(
                  label: '1000 m²',
                  color: Colors.blue,
                  icon: Icons.straighten,
                ),

                // Activities chips - ONLY THIS ONE, remove the duplicate
                ...controller.activities
                    .map((activity) => CategoryChip(
                          label: activity.name ?? 'Unknown Activity',
                          color: Colors.green,
                          icon: Icons.local_activity,
                        ))
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // About
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
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
                      LocalizationHelper.tr(
                          LocaleKeys.venue_description_default),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Venue Owner
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
                          (controller.venue.value?.host?.user?.username
                                      ?.isNotEmpty ??
                                  false)
                              ? controller.venue.value!.host!.user!.username![0]
                                  .toUpperCase()
                              : 'H',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.venue.value?.host?.user?.username ??
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
                  Obx(() {
                    final venue = controller.venue.value;

                    return venue != null
                        ? ContactHostWidget(
                            venue: venue,
                            style: ContactHostStyle.button,
                            customText: 'Contact',
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
                    const SnackBar(content: Text('Could not open Google Maps')),
                  );
                }
              }
            } catch (e) {
              // Handle error
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
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

  //Section 3
  Widget _buildFacilitiesSection(
      BuildContext context, VenueDetailController controller) {
    return Container(
      child: CustomTextButton(
        text: LocalizationHelper.tr(LocaleKeys.common_seeMore),
        onTap: () {
          Get.to(() => AboutDetail(
                venueName: controller.venue.value?.name ??
                    LocalizationHelper.tr(LocaleKeys.venue_facilities),
                venueDescription: controller.venue.value?.description ?? '',
                initialTabIndex: 1,
              ));
        },
        icon: Icons.arrow_forward,
        isrightIcon: true,
      ),
    );
  }

  //Section 4
  Widget _buildScheduleSection(
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
                LocalizationHelper.tr(LocaleKeys.venue_schedule),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextButton(
                text: LocalizationHelper.tr(LocaleKeys.common_showMore),
                onTap: () {},
                icon: Icons.arrow_forward,
                isrightIcon: true,
              ),
            ],
          ),
          Column(
            children: [
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_monday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_tuesday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_wednesday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_thursday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_friday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_saturday),
                  '7:00 - 21:00'),
              _buildScheduleItem(
                  LocalizationHelper.tr(LocaleKeys.common_sunday),
                  LocalizationHelper.tr(LocaleKeys.venue_closed)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

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
                'Reviews',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextButton(
                text: 'Show All',
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
                  'No reviews yet',
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
                                      (review.user?.username?.isNotEmpty ??
                                              false)
                                          ? review.user!.username![0]
                                              .toUpperCase()
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
                                          review.user?.username ?? 'Anonymous',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (review.createdAt != null)
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(review.createdAt!),
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
                                        index < (review.rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: index < (review.rating ?? 0)
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
                          'View all ${controller.reviews.length} reviews',
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
