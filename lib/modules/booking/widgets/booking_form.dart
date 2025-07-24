import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';

class BookingFormWidget extends StatelessWidget {
  final BookingController controller;
  final VenueModel venue; // Add venue as required parameter

  const BookingFormWidget({
    super.key, 
    required this.controller,
    required this.venue, // Make venue required
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Payment Summary Card
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
                    'Total Amount',
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

        // Book and Pay Button
        Obx(() {
          return PrimaryButton(
            isLoading: controller.isProcessing.value,
            text: controller.isProcessing.value 
              ? 'Creating Booking...' 
              : 'Book & Pay Now',
            onPressed: controller.isProcessing.value 
              ? null 
              : () => _handleBookingAndPayment(context, controller, venue),
            width: double.infinity,
            leftIcon: controller.isProcessing.value 
              ? Icons.hourglass_empty 
              : Icons.payment,
          );
        }),
        
        const SizedBox(height: 12),
        
        // Terms and Conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy. You will be redirected to a secure payment page.',
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

  void _handleBookingAndPayment(BuildContext context, BookingController controller, VenueModel venue) async {
    // Validate form first
    if (!controller.isFormValid()) {
      return;
    }

    // Show confirmation dialog
    final bool confirmed = await _showBookingConfirmation(context, controller, venue);
    
    if (confirmed) {
      // Use the payment-enabled booking method
      await controller.saveBookingWithPayment(venue);
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
                _buildConfirmationItem('Capacity', controller.selectedCapacity.value),
                _buildConfirmationItem('Total', 'Rp ${_formatCurrency(_calculateTotalPrice(context, controller, venue))}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will be redirected to a secure payment page after confirmation.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm & Pay'),
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
    // Use the existing method from controller if available
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