import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';

class MyRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String bottomNav = '/bottomNav';
  static const String profile = '/profile';
  static const String bookinglist = '/bookinglist';
  static const String promos = '/promos';
  static const String favorites = '/favorites';
  static const String detailVenue = '/detailVenue';

  static final pageRoutes = {
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),

    GetPage(name: home, page: () => HomePage()),
  };
}
