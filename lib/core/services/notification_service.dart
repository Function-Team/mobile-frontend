import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:get/get.dart';
import 'package:function_mobile/common/routes/routes.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _setupFirebaseMessaging();
  }

  Future<void> _initializeNotifications() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User declined or has not accepted permission');
      return;
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _setupFirebaseMessaging() async {
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $_fcmToken');
    
    if (_fcmToken != null) {
      await _updateFcmTokenToBackend(_fcmToken!);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _updateFcmTokenToBackend(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _updateFcmTokenToBackend(String token) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.putRequest(
        '/user/fcm-token',
        {'fcm_token': token},
      );
      
      if (response != null) {
        print('✅ FCM token updated successfully');
      }
    } catch (e) {
      print('❌ Failed to update FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Received foreground message: ${message.messageId}');
    
    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'function_app_channel',
      'Function App Notifications',
      channelDescription: 'Notifications for booking and payment updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Function App',
      message.notification?.body ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('📱 Notification tapped: ${message.data}');
    
    final data = message.data;
    final type = data['type'];
    final bookingId = data['booking_id'];

    switch (type) {
      case 'booking_confirmation':
        // Navigate to booking detail or payment page
        if (bookingId != null) {
          Get.toNamed(MyRoutes.bookingDetail, arguments: {'bookingId': bookingId});
        }
        break;
      case 'payment_success':
        // Navigate to booking detail or success page
        if (bookingId != null) {
          Get.toNamed(MyRoutes.bookingDetail, arguments: {'bookingId': bookingId});
        }
        break;
      default:
        // Navigate to home or notifications page
        Get.toNamed(MyRoutes.home);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Local notification tapped: ${response.payload}');
    // Handle local notification tap if needed
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('📨 Received background message: ${message.messageId}');
  // Handle background message if needed
}