import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:function_mobile/modules/home/controllers/promo_controller.dart';

Widget buildPromo() {
  // Lazily initialize the controller so it's only created when needed
  final PromoController controller = Get.put(PromoController());

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Promo',
            style: Get.theme.textTheme.headlineSmall,
          ),
        ],
      ),
      const SizedBox(height: 10),
      CarouselSlider.builder(
        itemCount: controller.promoImages.length,
        options: CarouselOptions(
          height: 220,
          viewportFraction: 1,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 8),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          onPageChanged: (index, reason) {
            controller.updateIndex(index);
          },
        ),
        itemBuilder: (BuildContext context, int index, int realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageWithLoader(
                imageUrl: controller.promoImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
      // Indicator dots
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: controller.promoImages.asMap().entries.map((entry) {
          return Obx(() => Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentIndex.value == entry.key
                      ? Get.theme.colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ));
        }).toList(),
      ),
    ],
  );
}
