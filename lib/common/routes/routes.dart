//This is routes for the app
//use this to define the routes for the app
//this makes it easier to navigate between pages

import 'package:function_mobile/modules/auth/bindings/auth_binding.dart';
import 'package:function_mobile/modules/auth/views/signup_page.dart';
import 'package:function_mobile/modules/home/bindings/home_binding.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/legal/privacy_policy_page.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/modules/legal/terms_of_service_page.dart';
import 'package:function_mobile/common/widgets/views/components_view.dart';
import 'package:function_mobile/modules/profile/bindings/edit_profile_binding.dart';
import 'package:function_mobile/modules/profile/bindings/profile_binding.dart';
import 'package:function_mobile/modules/profile/views/edit_profile_page.dart';
import 'package:function_mobile/modules/venue/bindings/venue_detail_binding.dart';
import 'package:function_mobile/modules/navigation/bindings/bottom_nav_binding.dart';
import 'package:function_mobile/modules/navigation/views/bottom_nav_view.dart';
import 'package:function_mobile/modules/venue/bindings/venue_list_binding.dart';
import 'package:function_mobile/modules/venue/views/venue_detail_page.dart';
import 'package:function_mobile/modules/venue/views/venue_list_page.dart';
import 'package:function_mobile/modules/profile/views/profile_page.dart';

import 'package:get/get.dart';

class MyRoutes {
  static const String componentView = '/componentView';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/homePage';
  static const String bottomNav = '/bottomNav';
  static const String profile = '/profile';
  static const String bookingList = '/bookingList';
  static const String favorites = '/favorites';
  static const String venueList = '/venueList';
  static const String venueDetail = '/venueDetail';
  static const String privacyPolicy = '/privacyPolicy';
  static const String termsOfService = '/termsOfService';
  static const String editProfile = '/editProfile';

  static final List<GetPage> pages = [
    //Components
    GetPage(name: componentView, page: () => ComponentsView()),

    //Auth
    GetPage(name: login, page: () => LoginPage(), binding: AuthBinding()),
    GetPage(name: signup, page: () => SignupPage(), binding: AuthBinding()),

    //Home
    GetPage(name: home, page: () => HomePage(), binding: HomeBinding()),

    //Venue
    GetPage(
        name: venueList,
        page: () => VenueListPage(),
        binding: VenueListBinding()),
    GetPage(
        name: venueDetail,
        page: () => VenueDetailPage(),
        binding: VenueDetailBinding()),

    //Profile
    GetPage(
        name: profile, page: () => ProfilePage(), binding: ProfileBinding()),
    GetPage(
        name: editProfile,
        page: () => EditProfilePage(),
        binding: EditProfileBinding()),

    //Navigation
    GetPage(
        name: bottomNav,
        page: () => BottomNavView(),
        binding: BottomNavBinding()),

    //Legal
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyPage()),
    GetPage(name: termsOfService, page: () => TermsOfServicePage()),
  ];
}
