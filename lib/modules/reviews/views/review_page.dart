import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/reviews/controllers/review_controller.dart';
import 'package:function_mobile/modules/reviews/widgets/review_card.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.find<ReviewController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(LocaleKeys.pages_reviewsPage)),
        centerTitle: true,
        actions: [
          // Add review button if we have a booking ID
          Obx(() => controller.bookingId.value > 0
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Get.toNamed(
                      MyRoutes.reviewForm,
                      arguments: {'bookingId': controller.bookingId.value},
                    );
                  },
                )
              : const SizedBox()),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: _buildReviewsList(controller),
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
                    text: LocalizationHelper.tr(LocaleKeys.common_retry),
                    onPressed: () => controller.loadReviewsByVenueId(
                        controller.venueId.value),
                  ),
                ],
              ),
            );
          } else {
            return _buildReviewsList(controller);
          }
        }),
      ),
    );
  }

  Widget _buildReviewsList(ReviewController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: controller.reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocalizationHelper.tr(LocaleKeys.labels_noReviewsYet),
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (controller.bookingId.value > 0)
                    PrimaryButton(
                      isLoading: false,
                      text: LocalizationHelper.tr(LocaleKeys.buttons_writeReview),
                      onPressed: () {
                        Get.toNamed(
                          MyRoutes.reviewForm,
                          arguments: {'bookingId': controller.bookingId.value},
                        );
                      },
                    ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: controller.reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(review: controller.reviews[index]);
              },
            ),
    );
  }
}