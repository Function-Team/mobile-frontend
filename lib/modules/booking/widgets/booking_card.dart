import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel bookingModel;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onViewVenue;
  final VoidCallback? onPayNow;

  const BookingCard({
    super.key,
    required this.bookingModel,
    required this.onTap,
    this.onCancel,
    this.onViewVenue,
    this.onPayNow,
  });

  // Check if booking is completed
  bool get isCompleted => bookingModel.isConfirmed && bookingModel.isPaid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Badge at top
            _buildStatusBadge(context),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Venue Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      imageUrl: bookingModel.place?.firstPictureUrl ?? '',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Booking Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingModel.place?.name ?? 'Unknown Venue',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                bookingModel.place?.address ?? 'No address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Date and Time
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              bookingModel.formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              bookingModel.formattedTimeRange,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        
                        // Payment Status for completed bookings
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Payment completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            if (!isCompleted) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String statusText;
    Color backgroundColor;
    Color textColor;

    if (isCompleted) {
      statusText = 'Completed';
      backgroundColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
    } else {
      statusText = bookingModel.statusDisplayName;
      backgroundColor = bookingModel.statusColor.withOpacity(0.1);
      textColor = bookingModel.statusColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Booking ID
          Text(
            '#${bookingModel.id}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Don't show action buttons for completed bookings
    if (bookingModel.status == BookingStatus.expired || 
        bookingModel.status == BookingStatus.cancelled ||
        isCompleted) {
      return const SizedBox.shrink();
    }

    // Check if booking is confirmed but not paid
    final bool needsPayment = bookingModel.isConfirmed && !bookingModel.isPaid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Pay Now button - priority for confirmed unpaid bookings
          if (needsPayment && onPayNow != null) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPayNow,
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // View Venue button
          if (onViewVenue != null && !needsPayment)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onViewVenue,
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View Venue'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          
          // Cancel button - only show if not confirmed or if confirmed but not paid
          if (onCancel != null && !needsPayment &&
              (bookingModel.status == BookingStatus.pending || 
               bookingModel.status == BookingStatus.confirmed)) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}