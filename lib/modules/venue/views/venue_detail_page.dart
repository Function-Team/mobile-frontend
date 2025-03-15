import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueDetailController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retryLoading,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        controller.venue.value?.firstPictureUrl != null &&
                                controller
                                    .venue.value!.firstPictureUrl!.isNotEmpty
                            ? _buildVenueImageHeader(context, controller)
                            : SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: -300,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildVenueTitleSection(context, controller),
                                  SizedBox(height: 12),
                                  _buildVenueType(
                                    controller.venue.value?.category?.name ??
                                        'Mansion',
                                    '${controller.venue.value?.maxCapacity ?? 100}',
                                    '1000 m²',
                                  ),
                                  Divider(height: 24, thickness: 0.5),
                                  _buildAboutVenue(controller
                                          .venue.value?.description ??
                                      'Venue for various events such as weddings, parties, exhibitions, etc., can be used for modern and calm themes.'),
                                  Divider(height: 24, thickness: 0.5),
                                  _buildVenueOwner(
                                      controller.venue.value?.host?.user
                                              ?.username ??
                                          'Kim Minji',
                                      controller),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 300),
                    _buildVenueLocation(
                        context,
                        controller.venue.value?.address ??
                            'Location not available'),
                    SizedBox(height: 8),
                    _buildFacilities(context, controller),
                    SizedBox(height: 8),
                    _buildReviews(controller),
                    SizedBox(height: 8),
                    _buildSchedule(context, controller),
                    SizedBox(height: 100),
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
      }),
    );
  }

  Widget _buildVenueImageHeader(
      BuildContext context, VenueDetailController controller) {
    return Stack(
      children: [
        GestureDetector(
            onTap: () {
              print('Image Clicked');
            },
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: NetworkImageWithLoader(
                imageUrl: controller.venue.value?.firstPictureUrl ?? '',
                fit: BoxFit.cover,
              ),
            )),
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueTitleSection(
      BuildContext context, VenueDetailController controller) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.venue.value?.name ?? 'Real Space',
                  style: TextStyle(
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
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(
                        ' ${controller.venue.value?.rating?.toStringAsFixed(1) ?? '5.0'} (${controller.venue.value?.reviewCount ?? '100'} Reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVenueType(
      String venueType, String capacityType, String venueSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(
            label: venueType,
            color: Colors.blue,
            isBackground: true,
          ),
          SizedBox(width: 8),
          CategoryChip(
            label: capacityType,
            color: Colors.blue,
            icon: Icons.groups_2,
            isBackground: true,
          ),
          SizedBox(width: 8),
          CategoryChip(
            label: venueSize,
            color: Colors.blue,
            icon: Icons.straighten,
            isBackground: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutVenue(String aboutVenue) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'About Venue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextButton(
                text: 'Selengkapnya',
                onTap: () {
                  print('See More Clicked');
                },
                icon: Icons.arrow_forward,
                isrightIcon: true,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            aboutVenue,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueOwner(String owner, VenueDetailController controller) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Text(
                  owner.isNotEmpty ? owner[0].toUpperCase() : '?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemilik Venue',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    owner,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          PrimaryButton(
            text: 'Hubungi',
            onPressed: () => controller.contactHost(),
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildVenueLocation(BuildContext context, String location) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              print('Location Clicked');
            },
          )
        ],
      ),
    );
  }
}

Widget _buildFacilities(
    BuildContext context, VenueDetailController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fasilitas',
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
          SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingFacilities.value) {
              return Center(child: CircularProgressIndicator());
            } else if (controller.facilities.isEmpty) {
              return Text('No facilities available');
            } else {
              final int midPoint = (controller.facilities.length / 2).ceil();
              final firstColumn = controller.facilities.sublist(
                  0,
                  midPoint > controller.facilities.length
                      ? controller.facilities.length
                      : midPoint);
              final secondColumn = controller.facilities.length > midPoint
                  ? controller.facilities.sublist(midPoint)
                  : <FacilityModel>[];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: firstColumn
                          .map((facility) => _buildFacilityItem(
                              facility.icon ?? Icons.check_box_outline_blank,
                              facility.name ?? 'Unknown',
                              facility.isAvailable ?? true))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: secondColumn
                          .map((facility) => _buildFacilityItem(
                              facility.icon ?? Icons.check_box_outline_blank,
                              facility.name ?? 'Unknown',
                              facility.isAvailable ?? true))
                          .toList(),
                    ),
                  ),
                ],
              );
            }
          }),
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
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        SizedBox(width: 4),
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red,
          size: 16,
        ),
      ],
    ),
  );
}

Widget _buildReviews(VenueDetailController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
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
          SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingReviews.value) {
              return Center(child: CircularProgressIndicator());
            } else if (controller.reviews.isEmpty) {
              return Text('No reviews available');
            } else {
              final displayedReviews = controller.reviews.take(2).toList();

              return Row(
                children: [
                  Expanded(
                    child: _buildReviewCard(
                      displayedReviews[0].user?.username ?? 'Anonymous',
                      displayedReviews[0].rating?.toDouble() ?? 0.0,
                      displayedReviews[0].comment ?? 'No comment',
                      displayedReviews[0].user?.profilePictureUrl,
                    ),
                  ),
                  if (displayedReviews.length > 1) ...[
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildReviewCard(
                        displayedReviews[1].user?.username ?? 'Anonymous',
                        displayedReviews[1].rating?.toDouble() ?? 0.0,
                        displayedReviews[1].comment ?? 'No comment',
                        displayedReviews[1].user?.profilePictureUrl,
                      ),
                    ),
                  ],
                ],
              );
            }
          }),
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
    padding: EdgeInsets.all(12),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Text(
              rating.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
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

Widget _buildPriceAndBooking(
  BuildContext context,
  VenueDetailController controller,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start From',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        )),
                    Row(
                      children: [
                        Text(
                          NumberFormat("#,##0", "id_ID")
                              .format(controller.venue.value?.price ?? 0),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                        ),
                        Text(' / hour',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]))
                      ],
                    ),
                    Text('Include tax',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]))
                  ],
                ),
              ),
              Expanded(
                child: SecondaryButton(
                  text: 'Book This',
                  onPressed: () => controller.bookVenue(),
                ),
              )
            ],
          )),
    ),
  );
}

Widget _buildSchedule(BuildContext context, VenueDetailController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
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
          Obx(() {
            if (controller.venue.value?.schedules == null ||
                controller.venue.value!.schedules!.isEmpty) {
              return Column(
                children: [
                  _buildScheduleItem('Monday', '08:00 - 17:00'),
                  _buildScheduleItem('Tuesday', '08:00 - 17:00'),
                  _buildScheduleItem('Wednesday', '08:00 - 17:00'),
                  _buildScheduleItem('Thursday', '08:00 - 17:00'),
                  _buildScheduleItem('Friday', '08:00 - 17:00'),
                  _buildScheduleItem('Saturday', '08:00 - 17:00'),
                  _buildScheduleItem('Sunday', 'Closed'),
                ],
              );
            } else {
              return Column(
                children: controller.venue.value!.schedules!.map((schedule) {
                  String timeRange = schedule.isClosed == true
                      ? 'Closed'
                      : '${schedule.openTime ?? "00:00"} - ${schedule.closeTime ?? "00:00"}';

                  return _buildScheduleItem(
                      schedule.day ?? 'Unknown', timeRange);
                }).toList(),
              );
            }
          }),
        ],
      ),
    ),
  );
}

Widget _buildScheduleItem(String day, String time) {
  return Container(
    padding: EdgeInsets.all(8),
    margin: EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    ),
  );
}
