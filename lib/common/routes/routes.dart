import 'package:function_mobile/modules/auth/bindings/auth_binding.dart';
import 'package:function_mobile/modules/auth/views/signup_page.dart';
import 'package:function_mobile/modules/home/bindings/home_binding.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/legal/privacy_policy_page.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/modules/legal/terms_of_service_page.dart';
import 'package:function_mobile/common/widgets/views/components_view.dart';
import 'package:function_mobile/modules/venue/bindings/venue_detail_binding.dart';
import 'package:function_mobile/modules/venue/views/venue_detail_page.dart';
import 'package:function_mobile/modules/venue/views/venue_list_page.dart';
import 'package:get/get.dart';

class MyRoutes {
  static const String componentView = '/componentView';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/homePage';
  static const String bottomNav = '/bottomNav';
  static const String profile = '/profile';
  static const String bookinglist = '/bookinglist';
  static const String promos = '/promos';
  static const String favorites = '/favorites';
  static const String listVenue = '/listVenue';
  static const String detailVenue = '/detailVenue';
  static const String privacyPolicy = '/privacyPolicy';
  static const String termsOfService = '/termsOfService';
  static const String searchFilter = '/searchFilter';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginPage(), binding: AuthBinding()),
    GetPage(name: signup, page: () => SignupPage(), binding: AuthBinding()),
    GetPage(name: home, page: () => HomePage(), binding: HomeBinding()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyPage()),
    GetPage(name: termsOfService, page: () => TermsOfServicePage()),
    GetPage(name: componentView, page: () => ComponentsView()),
    GetPage(
        name: listVenue, page: () => VenueListPage(), binding: VenueBinding()),
    GetPage(
        name: detailVenue,
        page: () => VenueDetailPage(),
        binding: VenueBinding()),
  ];
}
