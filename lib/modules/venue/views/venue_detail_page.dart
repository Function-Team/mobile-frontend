import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:intl/intl.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildVenueImageHeader(context),
                _buildVenueType('Meeting Room', '1-100', '100m²',
                    'Wonokromo, South Surabaya', 'Vickie Streich'),
                SizedBox(height: 16),
                _buildAboutVenue('a space for meeting, workshop, and seminar, '
                    'with a capacity of 50 people, equipped with a projector, '
                    'sound system, and whiteboard, suitable for small meetings'),
                SizedBox(height: 8),
                _buildVenueOwner('Vickie Streich'),
                SizedBox(height: 8),
                _buildVenueLocation(context, 'Wonokromo, South Surabaya'),
                SizedBox(height: 8),
                _buildFacilities(context),
                SizedBox(height: 8),
                _buildReviews(),
                SizedBox(height: 8),
                _buildSchedule(context),
                // Modify to show the Widget behind Fixed Price and Booking
                SizedBox(height: 100),
              ],
            ),
          ),
          // Fixed Price and Booking
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPriceAndBooking(context),
          ),
        ],
      ),
    );
  }

// This function return a widget that contains the venue image header
  Widget _buildVenueImageHeader(BuildContext context) {
    return Stack(
      children: [
        // Venue image
        GestureDetector(
          onTap: () {
            print('Image Clicked');
          },
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: NetworkImageWithLoader(imageUrl: ''),
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
              icon: Icon(Icons.arrow_back, color: Colors.black),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                        'Real Space',
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
                              ' 5.0 (100 Reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Icon(Icons.arrow_forward,
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
          ),
        ),
      ],
    );
  }

  Widget _buildVenueType(String venueType, String capacityType,
      String venueSize, String location, String owner) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue type tags
          Row(
            children: [
              CategoryChip(label: venueType, color: Colors.blue),
              SizedBox(width: 8),
              CategoryChip(
                label: capacityType,
                color: Colors.blue,
                icon: Icons.groups_2,
              ),
              SizedBox(width: 8),
              CategoryChip(
                  label: venueSize, color: Colors.blue, icon: Icons.straighten),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutVenue(String aboutVenue) {
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
                  'About Venue',
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
      ),
    );
  }

  Widget _buildVenueOwner(String owner) {
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
            Text(
              'Venue Owner',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    print('Owner Clicked');
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Text('V', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        owner,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  text: 'Contact',
                  onPressed: () {},
                  width: 100,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueLocation(BuildContext context, String location) {
    return GestureDetector(
      onTap: () {
        print('Location Clicked');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                print('Location Clicked');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: TextStyle(fontSize: 14),
                    ),
                    Icon(Icons.location_on,
                        color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFacilities(BuildContext context) {
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
            //Facilities Title
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
                //Navigation to see more
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
            //Facilities Items
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFacilityItem(Icons.chair, 'Chair', true),
                      _buildFacilityItem(Icons.table_bar, 'Table', true),
                      _buildFacilityItem(Icons.speaker, 'Speaker', true),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFacilityItem(Icons.wifi, 'Wifi', true),
                      _buildFacilityItem(Icons.local_parking, 'Parking', true),
                      _buildFacilityItem(Icons.ac_unit, 'AC', true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityItem(IconData? icon, String text, bool isAvailable) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          if (icon != null) ...[
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
        ],
      ),
    );
  }

  Widget _buildReviews() {
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
            Row(
              children: [
                Expanded(
                    child: _buildReviewCard('John', 5, 'Great place',
                        'https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg')),
                SizedBox(width: 12),
                Expanded(
                    child: _buildReviewCard('Richard', 4.8, 'Great place', '')),
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
                          Text(NumberFormat("#,##0", "id_ID").format(1900000),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                          Text(' / hour',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]))
                        ],
                      ),
                      Text('Include tax',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700]))
                    ],
                  ),
                ),
                Expanded(
                  child: SecondaryButton(text: 'Book This', onPressed: () {}),
                )
              ],
            )),
      ),
    );
  }

  Widget _buildSchedule(BuildContext context) {
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
            Column(
              children: [
                _buildScheduleItem('Monday', '08:00 - 17:00'),
                _buildScheduleItem('Tuesday', '08:00 - 17:00'),
                _buildScheduleItem('Wednesday', '08:00 - 17:00'),
                _buildScheduleItem('Thursday', '08:00 - 17:00'),
                _buildScheduleItem('Friday', '08:00 - 17:00'),
                _buildScheduleItem('Saturday', '08:00 - 17:00'),
                _buildScheduleItem('Sunday', 'Closed'),
              ],
            ),
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
}
