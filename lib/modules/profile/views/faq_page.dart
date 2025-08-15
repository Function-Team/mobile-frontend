import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  final Set<String> _expandedQuestions = <String>{};

  // FAQ Categories Data
  List<Map<String, dynamic>> get faqCategories => [
        {
          'id': 'payment',
          'title':
              LocalizationHelper.tr(LocaleKeys.faq_categories_payment_title),
          'icon': Icons.payment_outlined,
          'questions': [
            {
              'id': 'payment_methods',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_payment_payment_methods_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_payment_payment_methods_answer),
            },
            {
              'id': 'payment_failed',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_payment_payment_failed_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_payment_payment_failed_answer),
            },
          ]
        },
        {
          'id': 'booking',
          'title':
              LocalizationHelper.tr(LocaleKeys.faq_categories_booking_title),
          'icon': Icons.calendar_today_outlined,
          'questions': [
            {
              'id': 'how_to_book',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_booking_how_to_book_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_booking_how_to_book_answer),
            },
            {
              'id': 'booking_confirmation',
              'question': LocalizationHelper.tr(LocaleKeys
                  .faq_categories_booking_booking_confirmation_question),
              'answer': LocalizationHelper.tr(LocaleKeys
                  .faq_categories_booking_booking_confirmation_answer),
            },
          ]
        },
        {
          'id': 'cancellation',
          'title': LocalizationHelper.tr(
              LocaleKeys.faq_categories_cancellation_title),
          'icon': Icons.cancel_outlined,
          'questions': [
            {
              'id': 'how_to_cancel',
              'question': LocalizationHelper.tr(LocaleKeys
                  .faq_categories_cancellation_how_to_cancel_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_cancellation_how_to_cancel_answer),
            },
            {
              'id': 'cancellation_policy',
              'question': LocalizationHelper.tr(LocaleKeys
                  .faq_categories_cancellation_cancellation_policy_question),
              'answer': LocalizationHelper.tr(LocaleKeys
                  .faq_categories_cancellation_cancellation_policy_answer),
            },
          ]
        },
        {
          'id': 'account',
          'title':
              LocalizationHelper.tr(LocaleKeys.faq_categories_account_title),
          'icon': Icons.person_outline,
          'questions': [
            {
              'id': 'create_account',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_account_create_account_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_account_create_account_answer),
            },
            {
              'id': 'update_profile',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_account_update_profile_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_account_update_profile_answer),
            },
          ]
        },
        {
          'id': 'general',
          'title':
              LocalizationHelper.tr(LocaleKeys.faq_categories_general_title),
          'icon': Icons.help_outline,
          'questions': [
            {
              'id': 'app_features',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_app_features_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_app_features_answer),
            },
            {
              'id': 'contact_support',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_contact_support_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_contact_support_answer),
            },
            {
              'id': 'app_updates',
              'question': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_app_updates_question),
              'answer': LocalizationHelper.tr(
                  LocaleKeys.faq_categories_general_app_updates_answer),
            },
          ]
        },
      ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredQuestions {
    if (_searchQuery.isEmpty) {
      // Return all questions grouped by category
      return faqCategories
          .expand((category) => (category['questions'] as List)
              .map<Map<String, dynamic>>((question) => {
                    ...question as Map<String, dynamic>,
                    'categoryTitle': category['title'],
                    'categoryIcon': category['icon'],
                  }))
          .toList();
    }

    // Return filtered questions
    return faqCategories
        .expand((category) => (category['questions'] as List).where((question) {
              return (question['question'] as String)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  (question['answer'] as String)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
            }).map<Map<String, dynamic>>((question) => {
                  ...question as Map<String, dynamic>,
                  'categoryTitle': category['title'],
                  'categoryIcon': category['icon'],
                }))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(LocaleKeys.faq_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchQuery.isEmpty) {
      return _buildCategorizedView();
    } else {
      return _buildSearchResults();
    }
  }

  Widget _buildCategorizedView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqCategories.length,
      itemBuilder: (context, index) {
        final category = faqCategories[index];
        return _buildCategorySection(category, index);
      },
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category, int index) {
    final questions = category['questions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add spacing only between sections, not before the first one
        if (index > 0) const SizedBox(height: 24),

        // Category Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                category['icon'] as IconData,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                category['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
              ),
            ],
          ),
        ),

        // Questions
        ...questions.map<Widget>(
            (question) => _buildQuestionTile(question as Map<String, dynamic>)),
      ],
    );
  }

  Widget _buildSearchResults() {
    final questions = filteredQuestions;

    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionTile(questions[index], showCategory: true);
      },
    );
  }

  Widget _buildQuestionTile(Map<String, dynamic> question,
      {bool showCategory = false}) {
    final isExpanded = _expandedQuestions.contains(question['id']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedQuestions.remove(question['id']);
                } else {
                  _expandedQuestions.add(question['id'] as String);
                }
              });
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCategory) ...[
                  Row(
                    children: [
                      Icon(
                        question['categoryIcon'] as IconData,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        question['categoryTitle'] as String,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  question['question'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),

          // Answer
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question['answer'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.85),
                      ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationHelper.tr(LocaleKeys.faq_no_results_found),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.tr(LocaleKeys.faq_try_different_keywords),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
