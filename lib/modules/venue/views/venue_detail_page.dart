import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/custom_text_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/venue/widgets/category_chip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueDetailController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retryLoading,
                  child: const Text('Retry'),
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
                      children: [
                        // Image Carousel
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Obx(() {
                            if (controller.isLoadingImages.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // Tambahkan dummy images jika tidak ada gambar (UNTUK TESTING)
                            if (controller.venueImages.isEmpty) {
                              // Gunakan firstPictureUrl dari venue jika tersedia
                              if (controller.venue.value?.firstPictureUrl !=
                                      null &&
                                  controller.venue.value!.firstPictureUrl!
                                      .isNotEmpty) {
                                return Image.network(
                                  controller.venue.value!.firstPictureUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        "Error loading venue image: ${controller.venue.value?.firstPictureUrl}, error: $error");
                                    return _buildImagePlaceholder();
                                  },
                                );
                              } else {
                                // Fallback ke placeholder jika tidak ada gambar sama sekali
                                return _buildImagePlaceholder();
                              }
                            }

                            // Gunakan PageView untuk membuat slider gambar
                            return PageView.builder(
                              itemCount: controller.venueImages.length,
                              onPageChanged: (index) =>
                                  controller.currentImageIndex.value = index,
                              itemBuilder: (context, index) {
                                final image = controller.venueImages[index];
                                print(
                                    "Building image at index $index: ${image.imageUrl}");

                                return Image.network(
                                  image.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        "Error loading image: ${image.imageUrl}, error: $error");
                                    return _buildImagePlaceholder();
                                  },
                                );
                              },
                            );
                          }),
                        ),

                        // Indikator posisi gambar (dots)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Obx(() {
                            if (controller.venueImages.isEmpty ||
                                controller.venueImages.length <= 1) {
                              return const SizedBox();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.venueImages.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.currentImageIndex.value ==
                                            index
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Tombol back
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
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () => Get.back(result: true),
                            ),
                          ),
                        ),

                        // Content container
                        Container(
                          margin: EdgeInsets.only(top: 150),
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            children: [
                              _buildVenueInfoCard(context, controller),
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
      }),
    );
  }

// Helper method untuk membuat placeholder gambar
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              "Gambar tidak tersedia",
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueInfoCard(
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
                        controller.venue.value?.name ?? 'Data tidak ada',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(
                            ' ${controller.venue.value?.rating?.toStringAsFixed(1) ?? '5.0'} (${controller.venue.value?.reviewCount ?? '100'} Reviews)',
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
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 22),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                CategoryChip(
                  label: controller.venue.value?.category?.name ?? 'Mansion',
                  color: Colors.blue,
                ),
                CategoryChip(
                  label: '1-${controller.venue.value?.maxCapacity ?? 31}',
                  color: Colors.blue,
                  icon: Icons.groups_2,
                ),
                CategoryChip(
                  label: '1000 m²',
                  color: Colors.blue,
                  icon: Icons.straighten,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'About Venue',
                      style: TextStyle(
                        color: Colors.black,
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
                Text(
                  controller.venue.value?.description ??
                      '- Ruang meeting dengan nuansa kayu dan warna hangat\n- WiFi gratis',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pemilik Venue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Text(
                            (controller.venue.value?.host?.user?.username
                                        ?.isNotEmpty ??
                                    false)
                                ? controller
                                    .venue.value!.host!.user!.username![0]
                                    .toUpperCase()
                                : 'V',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.venue.value?.host?.user?.username ??
                              'Vickie Streich',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: 'Hubungi',
                      onPressed: () {},
                      width: 120,
                      height: 42,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(
      BuildContext context, VenueDetailController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () {
          print('Location Clicked');
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
                          'Pakuwon Square AK 2 No. 3, Jl. Yono Suwoyo No. 100, Surabaya',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.location_on,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection(
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
          const Text(
            'Fasilitas',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFacilityItem(Icons.table_bar, 'Table', true),
                    _buildFacilityItem(Icons.speaker, 'Speaker', true),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFacilityItem(Icons.local_parking, 'Parking', true),
                    _buildFacilityItem(Icons.ac_unit, 'AC', true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String text, bool isAvailable) {
    return SizedBox(
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
              const Text(
                'Reviews',
                style: TextStyle(
                  color: Colors.black,
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
          Row(
            children: [
              Expanded(
                child: _buildReviewCard(
                    'John',
                    5.0,
                    'I\'ve been consistently impressed with the quality...',
                    ''),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReviewCard(
                    'Richard',
                    4.8,
                    'I\'ve been consistently impressed with the quality...',
                    ''),
              ),
            ],
          ),
        ],
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
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              const Spacer(),
              Text(
                rating.toString(),
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
              const Text(
                'Schedule',
                style: TextStyle(
                  color: Colors.black,
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
              _buildScheduleItem('Monday', '7:00 - 21:00'),
              _buildScheduleItem('Tuesday', '7:00 - 21:00'),
              _buildScheduleItem('Wednesday', '7:00 - 21:00'),
              _buildScheduleItem('Thursday', '7:00 - 21:00'),
              _buildScheduleItem('Friday', '7:00 - 21:00'),
              _buildScheduleItem('Saturday', '7:00 - 21:00'),
              _buildScheduleItem('Sunday', 'Closed'),
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
                      'Start From',
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
                          '/Hour',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Text(
                      'Include tax',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SecondaryButton(
                  text: 'Book this',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
