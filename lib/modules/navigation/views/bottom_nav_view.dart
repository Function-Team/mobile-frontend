import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/views/bookings_list_page.dart';
// import 'package:function_mobile/modules/chat/views/chat_page.dart'; // DIHAPUS
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/profile/views/profile_page.dart';
import 'package:function_mobile/modules/favorite/views/favorites_page.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';

class BottomNavView extends StatelessWidget {
  final BottomNavController controller = Get.find();
  final LocalizationController localizationController = Get.find();

  BottomNavView({super.key});

  final List<Widget> pages = [
    HomePage(),
    BookingsListPage(),
    FavoritesPage(),
    // ChatPage(), // DIHAPUS
    ProfilePage(), // Index berubah dari 4 menjadi 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() {
        final _ = localizationController.currentLocale.value;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
              label: LocalizationHelper.tr(LocaleKeys.navigation_home),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.book_outlined, Icons.book, 1),
              label: LocalizationHelper.tr(LocaleKeys.navigation_bookings),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.favorite_outline, Icons.favorite, 2),
              label: LocalizationHelper.tr(LocaleKeys.navigation_favorites),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, Icons.person,
                  3), 
              label: LocalizationHelper.tr(LocaleKeys.navigation_profile),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNavIcon(IconData outlineIcon, IconData filledIcon, int index) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isSelected ? filledIcon : outlineIcon,
          key: ValueKey(isSelected),
          size: 24,
        ),
      );
    });
  }
}
