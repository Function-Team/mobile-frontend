import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/views/bookings_list_page.dart';
import 'package:function_mobile/modules/chat/views/chat_page.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/profile/views/profile_page.dart';
import 'package:function_mobile/modules/favorite/views/favorites_page.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';

class BottomNavView extends StatelessWidget {
  final BottomNavController controller = Get.find();

  BottomNavView({super.key});

  final List<Widget> pages = [
    HomePage(),
    BookingsListPage(),
    FavoritesPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
