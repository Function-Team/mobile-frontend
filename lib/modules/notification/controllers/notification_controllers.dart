import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/notification/models/notification_model.dart';

class NotificationController extends GetxController {
  final BookingService _bookingService = BookingService();

  // Observable states
  final RxBool hasBookingUpdates = false.obs;
  final RxInt updateCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Background timer
  Timer? _backgroundTimer;

  // Last known booking states for comparison
  List<BookingModel> _lastKnownBookings = [];

  // SharedPreferences keys
  static const String _keyHasUpdates = 'has_booking_updates';
  static const String _keyUpdateCount = 'booking_update_count';
  static const String _keyLastCheckTime = 'last_check_time';
  static const String _keyNotifications = 'stored_notifications';

  @override
  void onInit() {
    super.onInit();
    _loadSavedState();
    _loadStoredNotifications();
    _startBackgroundCheck();
  }

  @override
  void onClose() {
    _backgroundTimer?.cancel();
    super.onClose();
  }

  // Load saved notification state from SharedPreferences
  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hasBookingUpdates.value = prefs.getBool(_keyHasUpdates) ?? false;
      updateCount.value = prefs.getInt(_keyUpdateCount) ?? 0;

      print(
          '📱 NotificationController: Loaded saved state - Updates: ${hasBookingUpdates.value}, Count: ${updateCount.value}');
    } catch (e) {
      print('❌ NotificationController: Error loading saved state: $e');
    }
  }

  // Load stored notifications from SharedPreferences
  Future<void> _loadStoredNotifications() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_keyNotifications) ?? [];
      
      final loadedNotifications = notificationsJson
          .map((json) => NotificationModel.fromJson(jsonDecode(json)))
          .toList();
      
      // Sort by creation date (newest first)
      loadedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifications.value = loadedNotifications;
      
      print('📱 NotificationController: Loaded ${notifications.length} stored notifications');
    } catch (e) {
      print('❌ NotificationController: Error loading stored notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      
      await prefs.setStringList(_keyNotifications, notificationsJson);
      print('💾 NotificationController: Saved ${notifications.length} notifications');
    } catch (e) {
      print('❌ NotificationController: Error saving notifications: $e');
    }
  }

  // Save notification state to SharedPreferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasUpdates, hasBookingUpdates.value);
      await prefs.setInt(_keyUpdateCount, updateCount.value);
      await prefs.setInt(
          _keyLastCheckTime, DateTime.now().millisecondsSinceEpoch);

      print(
          '💾 NotificationController: State saved - Updates: ${hasBookingUpdates.value}, Count: ${updateCount.value}');
    } catch (e) {
      print('❌ NotificationController: Error saving state: $e');
    }
  }

  // Add new notification
  Future<void> addNotification(NotificationModel notification) async {
    notifications.insert(0, notification);
    
    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }
    
    await _saveNotifications();
    
    // Update badge count
    final unreadCount = notifications.where((n) => !n.isRead).length;
    updateCount.value = unreadCount;
    hasBookingUpdates.value = unreadCount > 0;
    
    await _saveState();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      
      // Update badge count
      final unreadCount = notifications.where((n) => !n.isRead).length;
      updateCount.value = unreadCount;
      hasBookingUpdates.value = unreadCount > 0;
      
      await _saveState();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    
    await _saveNotifications();
    
    updateCount.value = 0;
    hasBookingUpdates.value = false;
    
    await _saveState();
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadStoredNotifications();
    await forceCheck();
  }

  // Start background checking every 5 seconds
  void _startBackgroundCheck() {
    print('🚀 NotificationController: Starting background check (5s interval)');

    _backgroundTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (Get.currentRoute != '/booking-list') {
        _checkForBookingUpdates();
      }
    });
  }

  // Main logic to check for booking updates
  Future<void> _checkForBookingUpdates() async {
    try {
      print('🔍 NotificationController: Checking for booking updates...');

      // Get current bookings from API
      final currentBookings = await _bookingService.getUserBookings();

      if (currentBookings.isEmpty) {
        print('📝 NotificationController: No bookings found');
        return;
      }

      // First time check - save current state
      if (_lastKnownBookings.isEmpty) {
        _lastKnownBookings = List.from(currentBookings);
        print(
            '📚 NotificationController: Initial bookings saved (${currentBookings.length} bookings)');
        return;
      }

      // Check for differences
      final updates = _findBookingChanges(_lastKnownBookings, currentBookings);

      if (updates.isNotEmpty) {
        print(
            '🔔 NotificationController: Found ${updates.length} booking updates!');

        // Create notifications for each update
        for (String update in updates) {
          final notification = NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Update Booking',
            message: update,
            type: NotificationType.booking,
            createdAt: DateTime.now(),
          );
          
          await addNotification(notification);
          print('📋 Added notification: $update');
        }

        // Update last known state
        _lastKnownBookings = List.from(currentBookings);
      } else {
        print('NotificationController: No changes detected');
      }
    } catch (e) {
      print('NotificationController: Error checking updates: $e');
    }
  }

  // Compare old vs new bookings to find changes
  List<String> _findBookingChanges(
      List<BookingModel> oldBookings, List<BookingModel> newBookings) {
    List<String> changes = [];

    // Check for new bookings
    for (BookingModel newBooking in newBookings) {
      final oldBooking =
          oldBookings.firstWhereOrNull((b) => b.id == newBooking.id);

      if (oldBooking == null) {
        // New booking found
        changes.add('Booking baru: ${newBooking.placeName ?? 'Unknown'}');
      } else {
        // Check for status changes
        if (oldBooking.status != newBooking.status) {
          changes.add(
              'Status booking ${newBooking.placeName ?? 'Unknown'} berubah: ${_getStatusInIndonesian(oldBooking.status)} → ${_getStatusInIndonesian(newBooking.status)}');
        }

        // Check for payment status changes
        if (oldBooking.paymentStatus != newBooking.paymentStatus) {
          changes.add(
              'Status pembayaran ${newBooking.placeName ?? 'Unknown'} berubah: ${oldBooking.paymentStatus} → ${newBooking.paymentStatus}');
        }
      }
    }

    return changes;
  }

  String _getStatusInIndonesian(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.expired:
        return 'Kedaluwarsa';
    }
  }

  // Clear all notifications (called when user opens booking page)
  Future<void> clearNotifications() async {
    print('🧹 NotificationController: Clearing all notifications');

    hasBookingUpdates.value = false;
    updateCount.value = 0;

    await _saveState();

    // Refresh last known bookings to current state
    try {
      final currentBookings = await _bookingService.getUserBookings();
      _lastKnownBookings = List.from(currentBookings);
      print('🔄 NotificationController: Refreshed baseline booking state');
    } catch (e) {
      print('❌ NotificationController: Error refreshing baseline: $e');
    }
  }

  // Force check for updates (useful for testing or manual refresh)
  Future<void> forceCheck() async {
    print('🔄 NotificationController: Force checking updates...');
    await _checkForBookingUpdates();
  }

  // Reset notification system (useful for debugging)
  Future<void> resetNotifications() async {
    print('🔄 NotificationController: Resetting notification system');

    hasBookingUpdates.value = false;
    updateCount.value = 0;
    _lastKnownBookings.clear();
    notifications.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasUpdates);
    await prefs.remove(_keyUpdateCount);
    await prefs.remove(_keyLastCheckTime);
    await prefs.remove(_keyNotifications);
  }

  // Get unread notification count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // Navigation to notification page
  void goToNotifications() {
    Get.toNamed('/notifications');
  }
}
