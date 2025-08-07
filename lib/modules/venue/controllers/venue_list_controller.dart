import 'package:flutter/widgets.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class VenueListController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final RxList<VenueModel> venues = <VenueModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxString selectedCategory = ''.obs;
  final RxInt? selectedCategoryId = RxInt(-1);
  final RxList<String> categories = <String>[].obs;
  final RxMap<String, int> categoryMap = <String, int>{}.obs;
  

  // Debouncer untuk menghindari terlalu banyak API calls
  final _debouncer = Debouncer(delay: Duration(milliseconds: 300));

  // Tambahkan variabel untuk menyimpan parameter pencarian
  final Rx<Map<String, dynamic>> searchSummary = Rx<Map<String, dynamic>>({});
  final RxBool isFromAdvancedSearch = false.obs;

  // Tambahkan variabel untuk menyimpan parameter asli advanced search
  final Rx<Map<String, dynamic>> originalSearchParams =
      Rx<Map<String, dynamic>>({});
  static final RxMap<int, String> _categoryCache = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args.containsKey('searchResults') && args['isSearchResult'] == true) {
        isFromAdvancedSearch.value = true;
        final List<VenueModel> searchResults =
            args['searchResults'] as List<VenueModel>;
        venues.assignAll(searchResults);
        isLoading.value = false;

        if (args.containsKey('searchSummary')) {
          searchSummary.value = args['searchSummary'] as Map<String, dynamic>;
        }

        // Simpan parameter asli jika ada
        if (args.containsKey('originalSearchParams')) {
          originalSearchParams.value =
              args['originalSearchParams'] as Map<String, dynamic>;
        }

        loadCategories();
        return;
      }

      if (args.containsKey('searchQuery')) {
        final String query = args['searchQuery'] as String? ?? '';
        if (query.isNotEmpty) {
          searchController.text = query;
          searchQuery.value = query;
          // Tambahkan ke searchSummary
          searchSummary.value = {'activity': query};
          // Langsung cari dengan query dari argumen
          _performSearch();
        } else {
          // Jika tidak ada query, load semua venue
          loadVenues();
        }
      } else {
        // Jika tidak ada query, load semua venue
        loadVenues();
      }
    } else {
      // Jika tidak ada argumen, load semua venue
      loadVenues();
    }

    loadCategories();
  }

  @override
  void onClose() {
    // Hapus listener untuk searchController
    // searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchController.text;
    searchQuery.value = query;
    _debouncer(() {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      int? categoryId;
      if (selectedCategory.isNotEmpty) {
        categoryId = categoryMap[selectedCategory.value];
      }

      final results = await _venueRepository.searchVenues(
        searchQuery: searchQuery.value,
        categoryId: categoryId,
      );

      venues.assignAll(results);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Search failed. Please try again.';
      print('Error during search: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchVenues(String query) {
    searchQuery.value = query;
    searchController.text = query;
    _performSearch();
  }

  Future<void> loadVenues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedVenues = await _venueRepository.searchVenues();

      // Filter venue yang valid seperti di HomeController
      final filteredVenues = loadedVenues
          .where((venue) =>
              venue.id != null && venue.name != null && venue.price != null)
          .toList();

      if (filteredVenues.isEmpty) {
        hasError.value = true;
        errorMessage.value =
            'Tidak ada venue yang tersedia saat ini. Silakan coba lagi nanti.';
        venues.clear();
        return;
      }

      venues.assignAll(filteredVenues);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load venues. Please try again.';
      print('Error loading venues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      print('🔍 Loading categories directly from /category API...');
      final categories = await _venueRepository.getCategories();

      // ✅ Populate cache (sama seperti VenueDetailController)
      for (var category in categories) {
        if (category.id != null && category.name != null) {
          _categoryCache[category.id!] = category.name!;
          print('   - ${category.name} (ID: ${category.id})');
        }
      }

      Map<String, int> categoryMapping = {};
      for (var category in categories) {
        if (category.name != null && category.id != null) {
          categoryMapping[category.name!] = category.id!;
        }
      }

      categoryMap.assignAll(categoryMapping);
      this.categories.assignAll(categoryMapping.keys.toList());
      print('✅ Categories loaded and cached: ${this.categories.length}');
    } catch (e) {
      print('❌ Error loading categories: $e');
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _performSearch();
  }

  void clearCategory() {
    selectedCategory.value = '';
    _performSearch();
  }

  // Hapus method fetchVenues() karena sudah digabung dengan loadVenues()

  Future<void> refreshVenues() async {
    hasError.value = false;
    errorMessage.value = '';
    await _performAdvancedSearchRefresh();
  }

  // Method baru untuk refresh dengan parameter advanced search
  Future<void> _performAdvancedSearchRefresh() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Rekonstruksi parameter pencarian dari searchSummary
      Map<String, dynamic> searchParams = {};

      final summary = searchSummary.value;

      // Tambahkan parameter berdasarkan data yang tersimpan di searchSummary
      if (summary['activity'] != null &&
          summary['activity'].toString().isNotEmpty) {
        searchParams['search'] = summary['activity'];
      }

      // Jika ada parameter lain yang tersimpan, tambahkan di sini
      // Misalnya: city_id, capacity, date, time, dll
      // Catatan: Anda mungkin perlu menyimpan parameter asli dari advanced search
      // di searchSummary untuk rekonstruksi yang lebih akurat

      final results =
          await _venueRepository.searchAvailableVenues(searchParams);
      venues.assignAll(results);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Refresh failed. Please try again.';
      print('Error during refresh: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToVenueDetails(VenueModel venue) {
    if (venue.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {'venueId': venue.id});
    } else {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Cannot open venue details',
          type: SnackbarType.error);
    }
  }
  static String getCategoryName(VenueModel venue) {
    // Priority 1: Use category object from backend
    if (venue.category?.name != null && venue.category!.name!.isNotEmpty) {
      return venue.category!.name!;
    }
    
    // Priority 2: Use cached category name
    if (venue.categoryId != null && _categoryCache.containsKey(venue.categoryId!)) {
      return _categoryCache[venue.categoryId!]!;
    }
    
    // Priority 3: Fetch from repository if not cached
    if (venue.categoryId != null) {
      _fetchAndCacheCategoryName(venue.categoryId!);
      return 'Category ${venue.categoryId}'; // Temporary while fetching
    }
    
    return 'Uncategorized';
  }
  
  // ✅ TAMBAHAN: Fetch category name dan cache (sama seperti VenueDetailController)
  static Future<void> _fetchAndCacheCategoryName(int categoryId) async {
    try {
      final venueRepo = VenueRepository();
      final allCategories = await venueRepo.getCategories();
      
      // Cache all categories for future use
      for (var category in allCategories) {
        if (category.id != null && category.name != null) {
          _categoryCache[category.id!] = category.name!;
        }
      }
      
      print('✅ Categories cached: ${_categoryCache.length}');
    } catch (e) {
      print('❌ Error fetching category names: $e');
    }
  }
}
