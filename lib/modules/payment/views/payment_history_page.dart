// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:function_mobile/modules/payment/controllers/payment_controller.dart';
// import 'package:function_mobile/modules/payment/models/payment_model.dart';

// class PaymentHistoryPage extends StatelessWidget {
//   const PaymentHistoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final PaymentController controller = Get.put(PaymentController());

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Payment History',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.black87),
//             onPressed: () => controller.loadPaymentHistory(),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return _buildLoadingState();
//         }

//         if (controller.paymentHistory.isEmpty) {
//           return _buildEmptyState();
//         }

//         return _buildPaymentList(controller);
//       }),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text(
//             'Loading payment history...',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.receipt_long_outlined,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No Payment History',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'You haven\'t made any payments yet.\nStart booking to see your payment history.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             onPressed: () => Get.offNamed('/venues'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 32,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Browse Venues',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentList(PaymentController controller) {
//     return RefreshIndicator(
//       onRefresh: () => controller.loadPaymentHistory(),
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: controller.paymentHistory.length,
//         itemBuilder: (context, index) {
//           final payment = controller.paymentHistory[index];
//           return _buildPaymentCard(payment, controller);
//         },
//       ),
//     );
//   }

//   Widget _buildPaymentCard(PaymentModel payment, PaymentController controller) {
//     final PaymentStatus status = PaymentStatusExtension.fromString(payment.status) ?? PaymentStatus.pending;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () => _showPaymentDetails(payment, controller),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Payment #${payment.id}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   _buildStatusBadge(status, controller),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     _formatDate(payment.createdAt),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               if (payment.amount != null) ...[
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.payment,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Rp ${_formatCurrency(payment.amount!)}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//               ],
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Booking ID: ${payment.bookingId}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//               if (status == PaymentStatus.failed || status == PaymentStatus.expired) ...[
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton.icon(
//                       onPressed: () => controller.retryPayment(),
//                       icon: const Icon(Icons.refresh, size: 16),
//                       label: const Text('Retry'),
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.blue,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildStatusBadge(PaymentStatus status, PaymentController controller) {
//   //   final color = controller.getPaymentStatusColor(status);
//   //   final text = controller.getPaymentStatusText(status);
//   //   final icon = controller.getPaymentStatusIcon(status);
    
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//   //     decoration: BoxDecoration(
//   //       color: color.withOpacity(0.1),
//   //       borderRadius: BorderRadius.circular(20),
//   //       border: Border.all(color: color.withOpacity(0.3)),
//   //     ),
//   //     child: Row(
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Icon(icon, size: 14, color: color),
//   //         const SizedBox(width: 6),
//   //         Text(
//   //           text,
//   //           style: TextStyle(
//   //             fontSize: 12,
//   //             fontWeight: FontWeight.w600,
//   //             color: color,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   void _showPaymentDetails(PaymentModel payment, PaymentController controller) {
//     final PaymentStatus status = PaymentStatusExtension.fromString(payment.status) ?? PaymentStatus.pending;
    
//     showModalBottomSheet(
//       context: Get.context!,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         maxChildSize: 0.9,
//         minChildSize: 0.4,
//         expand: false,
//         builder: (context, scrollController) => Column(
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 controller: scrollController,
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Payment Details',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         _buildStatusBadge(status, controller),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     _buildDetailItem('Payment ID', '#${payment.id}'),
//                     _buildDetailItem('Booking ID', '#${payment.bookingId}'),
//                     _buildDetailItem('Date', _formatDate(payment.createdAt)),
//                     if (payment.amount != null)
//                       _buildDetailItem('Amount', 'Rp ${_formatCurrency(payment.amount!)}'),
//                     _buildDetailItem('Status', controller.getPaymentStatusText(status)),
//                     const SizedBox(height: 32),
//                     if (status == PaymentStatus.failed || status == PaymentStatus.expired) ...[
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             controller.retryPayment();
//                           },
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry Payment'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                     if (status == PaymentStatus.pending) ...[
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             controller.refreshPaymentStatus(payment.id!);
//                           },
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Check Status'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text('Close'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const Text(': '),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Unknown';
//     return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _formatCurrency(double amount) {
//     return amount.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//   }
// }