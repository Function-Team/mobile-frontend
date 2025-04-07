import 'package:function_mobile/modules/auth/views/signup_page.dart';
import 'package:function_mobile/modules/booking/views/booking_detail.dart';
import 'package:function_mobile/modules/booking/views/bookings_list_page.dart';
import 'package:function_mobile/modules/chat/bindings/chat_binding.dart';
import 'package:function_mobile/modules/chat/views/chat_page.dart';
import 'package:function_mobile/modules/chat/views/chatting_page.dart';
import 'package:function_mobile/modules/home/pages/capacity_selection_page.dart';
import 'package:function_mobile/modules/home/pages/date_selection_page.dart';
import 'package:function_mobile/modules/home/pages/search_activity_page.dart';
import 'package:function_mobile/modules/home/pages/search_location_page.dart';

import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/legal/privacy_policy_page.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/modules/legal/terms_of_service_page.dart';
import 'package:function_mobile/common/widgets/views/components_view.dart';
import 'package:function_mobile/modules/profile/views/edit_profile_page.dart';
import 'package:function_mobile/modules/venue/views/venue_detail_page.dart';
import 'package:function_mobile/modules/navigation/views/bottom_nav_view.dart';
import 'package:function_mobile/modules/venue/views/venue_list_page.dart';
import 'package:function_mobile/modules/profile/views/profile_page.dart';
import 'package:function_mobile/modules/settings/settings_page/views/settings_page.dart';
import 'package:get/get.dart';

// Feature-specific bindings are only required if they have
// dependencies not covered in the AppBinding
import 'package:function_mobile/modules/venue/bindings/venue_detail_binding.dart';
import 'package:function_mobile/modules/venue/bindings/venue_list_binding.dart';
import 'package:function_mobile/modules/profile/bindings/edit_profile_binding.dart';

class MyRoutes {
  static const String componentView = '/componentView';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/homePage';
  static const String bottomNav = '/bottomNav';
  static const String profile = '/profile';

  static const String bookingList = '/bookingList';
  static const String bookingDetail = '/bookingDetail';

  static const String favorites = '/favorites';
  static const String venueList = '/venueList';
  static const String venueDetail = '/venueDetail';
  static const String privacyPolicy = '/privacyPolicy';
  static const String termsOfService = '/termsOfService';
  static const String editProfile = '/editProfile';

  static const String settings = '/settings';

  static const String searchActivity = '/searchActivity';
  static const String searchCapacity = '/searchCapacity';
  static const String searchDate = '/searchDate';
  static const String searchLocation = '/searchLocation';

  static const String chat = '/chat';
  static const String chatting = '/chatting';

  static final List<GetPage> pages = [
    // Components
    GetPage(name: componentView, page: () => ComponentsView()),

    // Auth (no AuthBinding needed - controllers are in AppBinding)
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignupPage()),

    // Home (no HomeBinding needed - controllers are in AppBinding)
    GetPage(name: home, page: () => HomePage()),

    // Booking
    GetPage(name: bookingList, page: () => BookingsListPage()),
    GetPage(name: bookingDetail, page: () => BookingDetail()),

    // SearchFilter
    GetPage(name: searchActivity, page: () => SearchActivityPage()),
    GetPage(name: searchCapacity, page: () => CapacitySelectionPage()),
    GetPage(name: searchDate, page: () => DateSelectionPage()),
    GetPage(name: searchLocation, page: () => SearchLocationPage()),

    // Venue
    GetPage(
        name: venueList,
        page: () => VenueListPage(),
        binding: VenueListBinding()),
    GetPage(
        name: venueDetail,
        page: () => VenueDetailPage(),
        binding: VenueDetailBinding()),

    // Profile
    GetPage(name: profile, page: () => ProfilePage()),
    GetPage(
        name: editProfile,
        page: () => EditProfilePage(),
        binding: EditProfileBinding()),

    // Navigation
    GetPage(name: bottomNav, page: () => BottomNavView()),

    // Legal
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyPage()),
    GetPage(name: termsOfService, page: () => TermsOfServicePage()),

    // Settings
    GetPage(name: settings, page: () => SettingsPage()),

    // Chat
    GetPage(name: chat, page: () => ChatPage(), binding: ChatBinding()),
    GetPage(name: chatting, page: () => ChattingPage()),
  ];
}
