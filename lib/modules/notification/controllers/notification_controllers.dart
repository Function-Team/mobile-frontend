import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';

class NotificationController extends GetxController {
  final BookingService _bookingService = BookingService();

  // Observable states
  final RxBool hasBookingUpdates = false.obs;
  final RxInt updateCount = 0.obs;

  // Background timer
  Timer? _backgroundTimer;

  // Last known booking states for comparison
  List<BookingModel> _lastKnownBookings = [];

  // SharedPreferences keys
  static const String _keyHasUpdates = 'has_booking_updates';
  static const String _keyUpdateCount = 'booking_update_count';
  static const String _keyLastCheckTime = 'last_check_time';

  @override
  void onInit() {
    super.onInit();
    _loadSavedState();
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

  // Start background checking every 5 seconds
  void _startBackgroundCheck() {
    print('🚀 NotificationController: Starting background check (5s interval)');

    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (Get.currentRoute != '/booking-list') {
        // Only check when NOT on booking page
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

      if (currentBookings == null || currentBookings.isEmpty) {
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

        // Update state
        hasBookingUpdates.value = true;
        updateCount.value = updates.length;

        // Save to SharedPreferences
        await _saveState();

        // Update last known state
        _lastKnownBookings = List.from(currentBookings);

        // Log what changed
        for (String update in updates) {
          print('📋 Update: $update');
        }
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
        changes.add('New booking: ${newBooking.placeName ?? 'Unknown'}');
      } else {
        // Check for status changes
        if (oldBooking.status != newBooking.status) {
          changes.add(
              'Booking ${newBooking.placeName ?? 'Unknown'}: ${oldBooking.status.name} → ${newBooking.status.name}');
        }

        // Check for payment status changes
        if (oldBooking.paymentStatus != newBooking.paymentStatus) {
          changes.add(
              'Payment for ${newBooking.placeName ?? 'Unknown'}: ${oldBooking.paymentStatus} → ${newBooking.paymentStatus}');
        }
      }
    }

    return changes;
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
      if (currentBookings != null) {
        _lastKnownBookings = List.from(currentBookings);
        print('🔄 NotificationController: Refreshed baseline booking state');
      }
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasUpdates);
    await prefs.remove(_keyUpdateCount);
    await prefs.remove(_keyLastCheckTime);
  }

  // Get last check time for debugging
  Future<DateTime?> getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyLastCheckTime);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      return null;
    }
  }
}
