import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/common/routes/routes.dart';

// Top-level background handler (required by Firebase)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print('Background notification: ${message.notification?.title}');
}

class FirebaseService extends GetxService {
  static FirebaseService get instance => Get.find<FirebaseService>();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  String? _token;
  String? get token => _token;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Request permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Setup FCM
      await _setupFirebaseMessaging();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      print('Firebase service initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Firebase permission granted');
    } else {
      print('Firebase permission denied');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _setupFirebaseMessaging() async {
    // Get token
    _token = await _messaging.getToken();
    if (_token != null) {
      print('FCM Token received: ${_token!.substring(0, 20)}...');
      await _sendTokenToBackend(_token!);
    }
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      print('FCM Token refreshed');
      _sendTokenToBackend(newToken);
    });
    
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground notification received');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
      
      _showLocalNotification(message);
    });

    // Background/terminated app notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Background notification tapped');
      _handleNotificationTap(message);
    });
    
    // App launched from terminated state via notification
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        print('App launched from notification');
        _handleNotificationTap(message);
      }
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final apiService = Get.find<ApiService>();
      await apiService.postRequest('/user/fcm-token', {'fcm_token': token});
      print('FCM token sent to backend');
    } catch (e) {
      print('Failed to send FCM token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'function_app_channel',
      'Function App Notifications',
      channelDescription: 'Booking and payment notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Function App',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: message.data.toString(),
    );
  }

 void _handleNotificationTap(RemoteMessage message) {
  print('Notification tapped - Data: ${message.data}');
  
  final type = message.data['type'];
  final bookingIdStr = message.data['booking_id'];

  if (bookingIdStr != null) {
    final bookingId = int.tryParse(bookingIdStr.toString());
    if (bookingId != null) {
      switch (type) {
        case 'booking_confirmation':
          print('Navigating to booking detail for confirmation');
          Get.toNamed(MyRoutes.bookingDetail, arguments: bookingId);
          break;
          
        case 'payment_success':
          print('Navigating to booking detail for payment success');
          Get.toNamed(MyRoutes.bookingDetail, arguments: bookingId);
          break;
          
        default:
          print('Navigating to home');
          Get.toNamed(MyRoutes.home);
      }
    } else {
      print('Invalid booking ID: $bookingIdStr');
      Get.toNamed(MyRoutes.home);
    }
  } else {
    print('No booking ID in notification');
    Get.toNamed(MyRoutes.home);
  }
}

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped');
  }

  // Public method to test notifications
  Future<void> testNotification() async {
    await _showLocalNotification(
      RemoteMessage(
        notification: const RemoteNotification(
          title: 'Test Notification',
          body: 'This is a test notification from Firebase Service',
        ),
        data: {'type': 'test'},
      ),
    );
  }
}