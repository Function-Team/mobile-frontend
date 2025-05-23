import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:function_mobile/common/widgets/inputs/primary_text_field.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueModel venue = Get.arguments as VenueModel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('Book Venue',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVenueCard(context, venue),
              const SizedBox(height: 24),
              _buildBookingDetailsSection(context, venue),
              const SizedBox(height: 24),
              _buildGuestInformationSection(context),
              const SizedBox(height: 24),
              _buildPricingSummary(context, venue),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBookingBar(context, venue),
    );
  }

  Widget _buildVenueCard(BuildContext context, VenueModel venue) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWithLoader(
                  imageUrl: venue.firstPictureUrl ?? '',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name ?? 'Venue Name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.address ?? 'Address not available',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${venue.rating?.toStringAsFixed(1) ?? '0.0'} (${venue.ratingCount ?? 'No'} Reviews)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection(BuildContext context, VenueModel venue) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Selection
          Obx(() {
            final dateRange = controller.selectedDateRange.value;
            return _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: dateRange != null
                  ? '${DateFormat('MMM dd').format(dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(dateRange.end)}'
                  : 'Select dates',
              onTap: () => _selectDateRange(context),
            );
          }),

          const SizedBox(height: 12),

          // Time Selection
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDetailRow(
                      context,
                      icon: Icons.access_time,
                      label: 'Start Time',
                      value: controller.startTime.value?.format(context) ??
                          'Select time',
                      onTap: () => _selectStartTime(context),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildDetailRow(
                      context,
                      icon: Icons.access_time_filled,
                      label: 'End Time',
                      value: controller.endTime.value?.format(context) ??
                          'Select time',
                      onTap: () => _selectEndTime(context),
                    )),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Capacity Selection
          Obx(() => _buildDetailRow(
                context,
                icon: Icons.people,
                label: 'Capacity',
                value: '${controller.selectedCapacity.value} People',
                onTap: () => _showCapacityPicker(context),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const Spacer(),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestInformationSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            controller: controller.guestNameController,
            prefixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            label: 'Email Address',
            hintText: 'Enter your email',
            controller: controller.guestEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            label: 'Phone Number',
            hintText: 'Enter your phone number',
            controller: controller.guestPhoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            label: 'Special Requests (Optional)',
            hintText: 'Any special requirements or requests',
            controller: controller.specialRequestsController,
            maxLines: 3,
            prefixIcon: const Icon(Icons.note_add),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(BuildContext context, VenueModel venue) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),  
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final summary = controller.getBookingSummary(venue);
            return Column(
              children: [
                _buildPriceRow(
                    'Venue Price (${summary['number_of_days']} day${summary['number_of_days'] > 1 ? 's' : ''})',
                    summary['base_price']),
                _buildPriceRow('Service Fee', summary['service_fee']),
                _buildPriceRow('Tax (10%)', summary['tax']),
                const Divider(),
                _buildPriceRow(
                  'Total',
                  summary['total'],
                  isTotal: true,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Base price: IDR ${NumberFormat("#,##0", "id_ID").format(summary['price_per_day'])} per day × ${summary['number_of_days']} day${summary['number_of_days'] > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'IDR ${NumberFormat("#,##0", "id_ID").format(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(Get.context!).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingBar(BuildContext context, VenueModel venue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick price preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venue Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'IDR ${NumberFormat("#,##0", "id_ID").format(venue.price ?? 0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final summary = controller.getBookingSummary(venue);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'IDR ${NumberFormat("#,##0", "id_ID").format(summary['total'])}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isProcessing.value) {
                return Container(
                  height: 50,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return SecondaryButton(
                text: 'Confirm Booking',
                onPressed: () => controller.saveBooking(venue),
                width: double.infinity,
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper methods for selections
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: controller.selectedDateRange.value,
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      controller.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.endTime.value ??
          TimeOfDay(
              hour: (TimeOfDay.now().hour + 2) % 24,
              minute: TimeOfDay.now().minute),
    );
    if (picked != null) {
      controller.setEndTime(picked);
    }
  }

  void _showCapacityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Capacity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...controller.capacityOptions.map((capacity) {
                return Obx(() => RadioListTile<String>(
                      title: Text('$capacity People'),
                      value: capacity,
                      groupValue: controller.selectedCapacity.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setCapacity(value);
                          Navigator.pop(context);
                        }
                      },
                    ));
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
