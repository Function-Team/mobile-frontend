import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onViewVenue;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onCancel,
    this.onConfirm,
    this.onViewVenue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildVenueInfo(context),
              const SizedBox(height: 12),
              _buildBookingDetails(context),
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Booking #${booking.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(context),
          ],
        ),
        _buildTimeRemaining(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: booking.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        booking.statusDisplayName,
        style: TextStyle(
          color: booking.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeRemaining(BuildContext context) {
    if (booking.status != BookingStatus.pending) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      int.parse(booking.startTime.split(':')[0]),
      int.parse(booking.startTime.split(':')[1]),
    );

    if (bookingDateTime.isBefore(now)) {
      return const SizedBox.shrink();
    }

    final difference = bookingDateTime.difference(now);
    String timeText;

    if (difference.inDays > 0) {
      timeText = '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours}h';
    } else {
      timeText = '${difference.inMinutes}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfo(BuildContext context) {
    return Row(
      children: [
        // Venue image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageWithLoader(
            imageUrl: booking.place?.firstPictureUrl ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),

        // Venue details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.place?.name ?? 'Unknown Venue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.place?.address ?? 'Address not available',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (booking.place?.rating != null)
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.place!.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Quick actions
        Column(
          children: [
            if (onViewVenue != null)
              IconButton(
                onPressed: onViewVenue,
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: booking.formattedDate,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.access_time,
                  label: 'Time',
                  value: booking.formattedTimeRange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.schedule,
                  label: 'Duration',
                  value: _formatDuration(booking.duration),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: booking.place?.price != null
                      ? 'IDR ${NumberFormat("#,##0", "id_ID").format(booking.place!.price)}'
                      : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Show different actions based on booking status
    switch (booking.status) {
      case BookingStatus.pending:
        if (onCancel != null) {
          if (actions.isNotEmpty) actions.add(const SizedBox(width: 8));
          actions.add(
            Expanded(
              child: OutlineButton(
                text: 'Cancel',
                onPressed: onCancel!,
                textColor: Colors.red,
                outlineColor: Colors.red,
                height: 36,
              ),
            ),
          );
        }
        break;

      case BookingStatus.confirmed:
        actions.add(
          Expanded(
            child: OutlineButton(
              text: 'View Details',
              onPressed: onTap,
              height: 36,
            ),
          ),
        );

        // Show cancel only if booking is in the future
        final now = DateTime.now();
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          int.parse(booking.startTime.split(':')[0]),
          int.parse(booking.startTime.split(':')[1]),
        );

        if (bookingDateTime.isAfter(now) && onCancel != null) {
          actions.add(const SizedBox(width: 8));
          actions.add(
            Expanded(
              child: OutlineButton(
                text: 'Cancel',
                onPressed: onCancel!,
                textColor: Colors.red,
                outlineColor: Colors.red,
                height: 36,
              ),
            ),
          );
        }
        break;

      case BookingStatus.expired:
        actions.add(
          Expanded(
            child: OutlineButton(
              text: 'View Details',
              onPressed: onTap,
              height: 36,
            ),
          ),
        );
        break;

      case BookingStatus.cancelled:
        actions.add(
          Expanded(
            child: OutlineButton(
              text: 'View Details',
              onPressed: onTap,
              height: 36,
            ),
          ),
        );
        break;
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: actions);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
