import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:get/get.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(context, 'faq.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.tr(context, 'faq.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.tr(context, 'faq.subtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            // Example with arguments
            const SizedBox(height: 16),
            Text(
              LocalizationHelper.trArgs(
                  context, 'welcome_user', {'name': 'John'}),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Example with plural
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.trPlural(context, 'item_count', 5),
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),
            _buildFaqSection(
              context,
              LocalizationHelper.tr(context, 'faq.general_title'),
              [
                _FaqItem(
                  question: LocalizationHelper.tr(
                      context, 'faq.how_to_book_question'),
                  answer:
                      LocalizationHelper.tr(context, 'faq.how_to_book_answer'),
                ),
                _FaqItem(
                  question: LocalizationHelper.tr(
                      context, 'faq.cancel_booking_question'),
                  answer: LocalizationHelper.tr(
                      context, 'faq.cancel_booking_answer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(
      BuildContext context, String title, List<_FaqItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildFaqItem(context, item)).toList(),
      ],
    );
  }

  Widget _buildFaqItem(BuildContext context, _FaqItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({
    required this.question,
    required this.answer,
  });
}
