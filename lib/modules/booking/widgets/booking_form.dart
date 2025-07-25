import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';

class BookingFormWidget extends StatelessWidget {
  final BookingController controller;
  final VenueModel venue;

  const BookingFormWidget({
    super.key, 
    required this.controller,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Price Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(_calculateTotalPrice(context, controller, venue))}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Including all fees and taxes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Confirm Booking Button (No payment)
        Obx(() {
          return PrimaryButton(
            isLoading: controller.isProcessing.value,
            text: controller.isProcessing.value 
              ? 'Creating Booking...' 
              : 'Confirm Booking',
            onPressed: controller.isProcessing.value 
              ? null 
              : () => _handleBookingConfirmation(context, controller, venue),
            width: double.infinity,
            leftIcon: controller.isProcessing.value 
              ? Icons.hourglass_empty 
              : Icons.check_circle,
          );
        }),
        
        const SizedBox(height: 16),
        
        // Important Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Process',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1. Your booking will be sent to the venue admin\n'
                      '2. Wait for admin confirmation (usually within 24 hours)\n'
                      '3. Once confirmed, you can proceed with payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Terms and Conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_box,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleBookingConfirmation(BuildContext context, BookingController controller, VenueModel venue) async {
    // Validate form first
    if (!controller.isFormValid()) {
      return;
    }

    // Show confirmation dialog
    final bool confirmed = await _showBookingConfirmation(context, controller, venue);
    
    if (confirmed) {
      // Use the new method that only creates booking
      await controller.saveBookingOnly(venue);
    }
  }

  Future<bool> _showBookingConfirmation(BuildContext context, BookingController controller, VenueModel venue) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please confirm your booking details:'),
                const SizedBox(height: 16),
                _buildConfirmationItem('Venue', venue.name ?? 'Unknown'),
                _buildConfirmationItem('Date', _formatDate(controller.selectedDateRange.value?.start)),
                _buildConfirmationItem('Time', _formatTimeRange(context, controller)),
                _buildConfirmationItem('Capacity', '${controller.selectedCapacity.value} people'),
                _buildConfirmationItem('Guest Name', controller.guestNameController.text),
                _buildConfirmationItem('Total Price', 'Rp ${_formatCurrency(_calculateTotalPrice(context, controller, venue))}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This booking will require admin approval',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalPrice(BuildContext context, BookingController controller, VenueModel venue) {
    final summary = controller.getBookingSummary(venue);
    return summary['total']?.toDouble() ?? 0.0;
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeRange(BuildContext context, BookingController controller) {
    final start = controller.startTime.value;
    final end = controller.endTime.value;
    if (start == null || end == null) return 'Not selected';
    
    return '${start.format(context)} - ${end.format(context)}';
  }
}