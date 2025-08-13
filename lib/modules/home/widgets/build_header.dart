import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/notification/controllers/notification_controllers.dart';

Widget buildHeader(
  BuildContext context, {
  required String name,
  required String? profilePicture,
  required VoidCallback onTapProfile,
}) {
  return Row(
    children: [
      Expanded(
        flex: 10,
        child: GestureDetector(
          onTap: onTapProfile,
          child: Row(
            children: [
              profilePicture != null && profilePicture.isNotEmpty
                  ? NetworkImageWithLoader(
                      imageUrl: profilePicture,
                      width: 40,
                      height: 40,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[400],
                      child: Text(
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
                LocalizationHelper.tr(LocaleKeys.common_hello),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.grey[300]),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: GetBuilder<NotificationController>(
          builder: (controller) {
            return GestureDetector(
              onTap: () => controller.goToNotifications(),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                  Obx(() {
                    if (controller.hasBookingUpdates.value &&
                        controller.updateCount.value > 0) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            controller.updateCount.value > 99
                                ? '99+'
                                : controller.updateCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}
