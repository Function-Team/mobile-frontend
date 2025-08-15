import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/reviews/controllers/review_controller.dart';
import 'package:function_mobile/modules/reviews/widgets/review_form.dart';
import 'package:get/get.dart';

class ReviewFormPage extends StatelessWidget {
  const ReviewFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<ReviewController>();
    final int bookingId = Get.arguments?['bookingId'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(LocaleKeys.buttons_writeReview)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: ReviewForm(bookingId: bookingId),
          ),
        ),
      ),
    );
  }
}