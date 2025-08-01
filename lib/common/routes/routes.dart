import 'package:function_mobile/modules/auth/views/email_verification_page.dart';
import 'package:function_mobile/modules/auth/views/signup_page.dart';
import 'package:function_mobile/modules/booking/bindings/booking_binding.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/views/booking_detail.dart';
import 'package:function_mobile/modules/booking/views/booking_page.dart';
import 'package:function_mobile/modules/booking/views/bookings_list_page.dart';
import 'package:function_mobile/modules/chat/bindings/chat_binding.dart';
import 'package:function_mobile/modules/chat/views/chat_page.dart';
import 'package:function_mobile/modules/chat/views/chatting_page.dart';
import 'package:function_mobile/modules/home/pages/search_activity_page.dart';
import 'package:function_mobile/modules/favorite/views/favorites_page.dart';
import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:function_mobile/modules/legal/privacy_policy_page.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/modules/legal/terms_of_service_page.dart';
import 'package:function_mobile/common/widgets/views/widgets_view.dart';
import 'package:function_mobile/modules/payment/models/payment_model.dart';
import 'package:function_mobile/modules/payment/views/payment_page.dart';
import 'package:function_mobile/modules/payment/views/payment_status_page.dart';
import 'package:function_mobile/modules/profile/views/edit_profile_page.dart';
import 'package:function_mobile/modules/reviews/bindings/review_binding.dart';
import 'package:function_mobile/modules/reviews/views/review_form_page.dart';
import 'package:function_mobile/modules/reviews/views/review_page.dart';
import 'package:function_mobile/modules/splash/views/splash_screen.dart';
import 'package:function_mobile/modules/venue/views/venue_detail_page.dart';
import 'package:function_mobile/modules/navigation/views/bottom_nav_view.dart';
import 'package:function_mobile/modules/venue/views/venue_list_page.dart';
import 'package:function_mobile/modules/profile/views/profile_page.dart';
import 'package:function_mobile/modules/settings/settings_page/views/settings_page.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/fullscreen_image_gallery.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/bindings/venue_detail_binding.dart';
import 'package:function_mobile/modules/venue/bindings/venue_list_binding.dart';
import 'package:function_mobile/modules/profile/bindings/edit_profile_binding.dart';

class MyRoutes {
  static const String componentView = '/componentView';

  // Splash Screen
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailVerification = '/emailVerification';

  // Home
  static const String home = '/homePage';

  // Navigation
  static const String bottomNav = '/bottomNav';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';

  // Booking
  static const String bookingPage = '/bookingPage';
  static const String bookingList = '/bookingList';
  static const String bookingDetail = '/bookingDetail';

  // Favorites
  static const String favorites = '/favorites';

  // Venue
  static const String venueList = '/venueList';
  static const String venueDetail = '/venueDetail';

  // Legal
  static const String privacyPolicy = '/privacyPolicy';
  static const String termsOfService = '/termsOfService';

  // Settings
  static const String settings = '/settings';

  // SearchFilter
  static const String searchActivity = '/searchActivity';
  static const String searchCapacity = '/searchCapacity';
  static const String searchDate = '/searchDate';
  static const String searchLocation = '/searchLocation';

  // Chat
  static const String chat = '/chat';
  static const String chatting = '/chatting';

  //ImageGallery
  static const String imageGallery = '/image-gallery';

  // Payment
  static const String payment = '/payment';
  static const String paymentStatus = '/payment-status';
  static const String paymentHistory = '/payment-history';

  // Review
  static const String reviewPage = '/review-page';
  static const String reviewForm = '/review-form';

  // Define the routes for the app

  static final List<GetPage> pages = [
    // Components
    GetPage(name: componentView, page: () => ComponentsView()),

    // Splash Screen
    GetPage(name: splash, page: () => const SplashScreen()),

    // Auth (no AuthBinding needed - controllers are in AppBinding)
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignupPage()),
    GetPage(name: emailVerification, page: () => EmailVerificationPage()),

    // Home (no HomeBinding needed - controllers are in AppBinding)
    GetPage(name: home, page: () => HomePage()),

    // Booking
    GetPage(
        name: bookingPage,
        page: () => const BookingPage(),
        binding: BookingBinding()),
    GetPage(
      name: bookingList,
      page: () => BookingListPage(),
    ),
    GetPage(
        name: bookingDetail,
        page: () => BookingDetailPage(),
        binding: BookingBinding()),

    // SearchFilter
    GetPage(name: searchActivity, page: () => SearchActivityPage()),

    GetPage(
      name: favorites,
      page: () => FavoritesPage(),
    ),

    // Venue
    GetPage(
        name: venueList,
        page: () => VenueListPage(),
        binding: VenueListBinding()),
    GetPage(
        name: venueDetail,
        page: () => VenueDetailPage(),
        binding: VenueDetailBinding()),
    //Image Gallery
    GetPage(
      name: imageGallery,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final images = args?['images'] as List<dynamic>? ?? [];
        final initialIndex = args?['initialIndex'] as int? ?? 0;

        return FullscreenImageGallery(
          images: images,
          initialIndex: initialIndex,
        );
      },
    ),

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

    GetPage(
      name: imageGallery,
      page: () => FullscreenImageGallery(
          images: Get.arguments['images'] ?? [],
          initialIndex: Get.arguments['initialIndex'] ?? 0),
    ),
    // Payment
    GetPage(
      name: payment,
      page: () {
        final BookingModel booking = Get.arguments as BookingModel;
        return PaymentPage(booking: booking);
      },
    ),
    GetPage(
      name: MyRoutes.paymentStatus,
      page: () {
        final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
        return PaymentStatusPage(
          paymentId: args['paymentId'] as int,
          status: args['status'] as PaymentStatus,
        );
      },
    ),
    // GetPage(name: MyRoutes.paymentHistory, page: () => const PaymentHistoryPage()),
    GetPage(
      name: reviewPage,
      page: () => const ReviewPage(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: reviewForm,
      page: () => const ReviewFormPage(),
      binding: ReviewBinding(),
    ),
  ];
}
