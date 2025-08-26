import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/favorite/controllers/favorites_controller.dart';
import 'package:function_mobile/modules/favorite/widgets/favorite_card.dart';
import 'package:get/get.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          LocalizationHelper.tr(LocaleKeys.appBarTitles_favorites),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          Obx(() => controller.favorites.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.favorites.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.favorites.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadFavorites();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          LocalizationHelper.tr(LocaleKeys.favorites_noFavorites),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            LocalizationHelper.tr(LocaleKeys.favorites_noFavoritesMessage),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          width: 200,
                          text: LocalizationHelper.tr(LocaleKeys.favorites_exploreVenues),
                          onPressed: () => controller.goToHome(),
                          isLoading: false,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadFavorites();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.separated(
              itemCount: controller.favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return FavoriteCard(favorite: controller.favorites[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}