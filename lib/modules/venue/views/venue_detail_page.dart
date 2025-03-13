import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueDetailController controller = Get.find<VenueDetailController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading venue data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.retryLoading,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Content
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildVenueImageHeader(context, controller),
                  const SizedBox(height: 16),
                  _buildVenueTypeCard(
                    context,
                    controller.venue.value?.category?.name ??
                        "Data gagal difetch",
                    "${controller.venue.value?.maxCapacity ?? 0}",
                    "data tidak ada",
                  ),
                  const SizedBox(height: 16),
                  _buildAboutVenueCard(
                    context,
                    controller.venue.value?.name ?? "Real Space",
                    controller.venue.value?.description ??
                        "Venue for various events such as weddings, parties, exhibitions, etc., can be used for modern and calm themes.",
                  ),
                  const SizedBox(height: 16),
                  _buildVenueOwnerCard(
                    context,
                    controller,
                    controller.venue.value?.host?.user?.username ?? "Kim Minji",
                  ),
                  const SizedBox(height: 16),
                  _buildVenueLocation(
                    context,
                    controller.venue.value?.address ??
                        "Wonokromo, South Surabaya",
                  ),
                  const SizedBox(height: 16),
                  _buildFacilities(context, controller),
                  const SizedBox(height: 16),
                  _buildReviews(context, controller),
                  const SizedBox(height: 16),
                  _buildSchedule(context, controller),
                  // Space at bottom to ensure content isn't hidden by price and booking section
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Fixed Price and Booking
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPriceAndBooking(context, controller),
            ),
          ],
        );
      }),
    );
  }

  // This function returns a widget that contains the venue image header
  Widget _buildVenueImageHeader(
      BuildContext context, VenueDetailController controller) {
    return Stack(
      children: [
        // Venue image
        GestureDetector(
          onTap: () {
            // Handle image tap to show full screen gallery
            print('Image Clicked');
          },
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: controller.venue.value?.firstPictureUrl != null
                ? NetworkImageWithLoader(
                    imageUrl: controller.venue.value!.firstPictureUrl!,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('No image available'),
                    ),
                  ),
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
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Venue info card at bottom of image
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.venue.value?.name ?? "Real Space",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('Rating Clicked');
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            Text(
                              ' ${controller.venue.value?.rating?.toStringAsFixed(1) ?? "5.0"} (${controller.venue.value?.reviewCount ?? 100} Reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Icon(Icons.arrow_forward,
                                color: Colors.grey, size: 16),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {
                        // Share venue
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.black),
                      onPressed: () {
                        // Add to favorites
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueTypeCard(
    BuildContext context,
    String venueType,
    String capacityType,
    String venueSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CategoryChip(
            label: venueType.isNotEmpty ? venueType : "Mansion",
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: "1-$capacityType",
            icon: Icons.groups_2,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: venueSize,
            icon: Icons.straighten,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  // Updated to match the new card UI style from the image
  Widget _buildAboutVenueCard(
      BuildContext context, String venueName, String aboutVenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
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
                const Text(
                  'About Venue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextButton(
                  text: 'Selengkapnya',
                  onTap: () {
                    // Show full description
                    print('See More Clicked');
                  },
                  icon: Icons.arrow_forward,
                  isrightIcon: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aboutVenue,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to match the new card UI style from the image
  Widget _buildVenueOwnerCard(
    BuildContext context,
    VenueDetailController controller,
    String owner,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemilik Venue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: controller
                                  .venue.value?.host?.user?.profilePictureUrl !=
                              null
                          ? ClipOval(
                              child: NetworkImageWithLoader(
                                imageUrl: controller.venue.value!.host!.user!
                                    .profilePictureUrl!,
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Text(
                              owner.isNotEmpty ? owner[0].toUpperCase() : "V",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      owner,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  text: 'Hubungi',
                  onPressed: controller.contactHost,
                  width: 120,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueLocation(
    BuildContext context,
    String location,
  ) {
    return GestureDetector(
      onTap: () {
        // Open map
        print('Location Clicked');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilities(
      BuildContext context, VenueDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facilities Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fasilitas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Navigation to see more
                CustomTextButton(
                  text: 'See more',
                  onTap: () {
                    print('See More Clicked');
                  },
                  icon: Icons.arrow_forward,
                  isrightIcon: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Loading state or error state
            if (controller.isLoadingFacilities.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.facilities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No facilities data available'),
              )
            // Facilities Items displayed in two columns
            else
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.facilities
                          .take(controller.facilities.length ~/ 2 +
                              controller.facilities.length % 2)
                          .map((facility) => _buildFacilityItem(
                                facility.icon ?? Icons.apps,
                                facility.name ?? "Data gagal difetch",
                                facility.isAvailable ?? true,
                              ))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.facilities
                          .skip(controller.facilities.length ~/ 2 +
                              controller.facilities.length % 2)
                          .map((facility) => _buildFacilityItem(
                                facility.icon ?? Icons.apps,
                                facility.name ?? "Data gagal difetch",
                                facility.isAvailable ?? true,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String text, bool isAvailable) {
    return Container(
      height: 30,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(width: 4),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(BuildContext context, VenueDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextButton(
                  text: 'See more',
                  onTap: () {
                    print('See More Clicked');
                  },
                  icon: Icons.arrow_forward,
                  isrightIcon: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Show loading, error, or reviews
            if (controller.isLoadingReviews.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No reviews yet'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: controller.reviews.isNotEmpty
                        ? _buildReviewCard(
                            controller.reviews[0].user?.username ??
                                "Data gagal difetch",
                            controller.reviews[0].rating?.toDouble() ?? 0.0,
                            controller.reviews[0].comment ??
                                "Data gagal difetch",
                            controller.reviews[0].user?.profilePictureUrl,
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: controller.reviews.length > 1
                        ? _buildReviewCard(
                            controller.reviews[1].user?.username ??
                                "Data gagal difetch",
                            controller.reviews[1].rating?.toDouble() ?? 0.0,
                            controller.reviews[1].comment ??
                                "Data gagal difetch",
                            controller.reviews[1].user?.profilePictureUrl,
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    double rating,
    String reviews,
    String? profilePicture,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[400],
                child: profilePicture != null && profilePicture.isNotEmpty
                    ? ClipOval(
                        child: NetworkImageWithLoader(
                          imageUrl: profilePicture,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reviews,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule(
      BuildContext context, VenueDetailController controller) {
    // Default schedule if none is available from API
    final defaultSchedule = [
      {'day': 'Monday', 'time': '08:00 - 17:00'},
      {'day': 'Tuesday', 'time': '08:00 - 17:00'},
      {'day': 'Wednesday', 'time': '08:00 - 17:00'},
      {'day': 'Thursday', 'time': '08:00 - 17:00'},
      {'day': 'Friday', 'time': '08:00 - 17:00'},
      {'day': 'Saturday', 'time': '08:00 - 17:00'},
      {'day': 'Sunday', 'time': 'Closed'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextButton(
                  text: 'See more',
                  onTap: () {
                    print('See More Clicked');
                  },
                  icon: Icons.arrow_forward,
                  isrightIcon: true,
                ),
              ],
            ),

            // Display schedules from API if available, otherwise use default
            if (controller.venue.value?.schedules?.isNotEmpty == true)
              Column(
                children: controller.venue.value!.schedules!.map((schedule) {
                  return _buildScheduleItem(
                      schedule.day ?? "Data gagal difetch",
                      schedule.isClosed == true
                          ? "Closed"
                          : "${schedule.openTime ?? '00:00'} - ${schedule.closeTime ?? '00:00'}");
                }).toList(),
              )
            else
              Column(
                children: defaultSchedule.map((schedule) {
                  return _buildScheduleItem(
                    schedule['day'] ?? "Data gagal difetch",
                    schedule['time'] ?? "Data gagal difetch",
                  );
                }).toList(),
              ),
          ],
        ),
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
            style: TextStyle(
                fontSize: 12,
                color: time.toLowerCase() == 'closed'
                    ? Colors.red
                    : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndBooking(
    BuildContext context,
    VenueDetailController controller,
  ) {
    int displayPrice = controller.venue.value?.price ?? 0;
    if (displayPrice == 0 &&
        controller.venue.value?.rooms?.isNotEmpty == true) {
      displayPrice = controller.venue.value!.rooms!.fold<int>(
        controller.venue.value!.rooms!.first.price ?? 0,
        (min, room) =>
            room.price != null && room.price! < min ? room.price! : min,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
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
                        'Start From',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            NumberFormat("#,##0", "id_ID").format(displayPrice),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' / hour',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          )
                        ],
                      ),
                      Text(
                        'Include tax',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SecondaryButton(
                    text: 'Book This',
                    onPressed: controller.bookVenue,
                  ),
                )
              ],
            )),
      ),
    );
  }
}
