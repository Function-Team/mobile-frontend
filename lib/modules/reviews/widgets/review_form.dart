import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/reviews/controllers/review_controller.dart';
import 'package:get/get.dart';

class ReviewForm extends StatelessWidget {
  final int bookingId;

  const ReviewForm({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.find<ReviewController>();
    controller.bookingId.value = bookingId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                controller.isEditMode.value ? 'Edit Review' : 'Write a Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              )),
          const SizedBox(height: 16),
          Text(
            'Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < controller.rating.value
                          ? Icons.star
                          : Icons.star_border,
                      color: index < controller.rating.value
                          ? Colors.amber
                          : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () {
                      controller.rating.value = index + 1;
                    },
                  );
                }),
              )),
          const SizedBox(height: 16),
          Text(
            'Comment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: LocalizationHelper.tr(LocaleKeys.forms_reviewPlaceholder),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => PrimaryButton(
                width: double.infinity,
                text: controller.isEditMode.value
                    ? 'Update Review'
                    : 'Submit Review',
                isLoading: controller.isSubmitting.value,
                onPressed: controller.submitReview,
              )),
        ],
      ),
    );
  }
}
