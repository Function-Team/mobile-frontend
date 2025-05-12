import 'package:flutter/widgets.dart';
import 'package:function_mobile/common/routes/routes.dart';
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

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);

    // Ambil parameter pencarian dari argumen jika ada
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('searchQuery')) {
      final String query = args['searchQuery'] as String? ?? '';
      if (query.isNotEmpty) {
        searchController.text = query;
        searchQuery.value = query;
        // Langsung cari dengan query dari argumen
        _performSearch();
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
    searchController.removeListener(_onSearchChanged);
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
      venues.assignAll(loadedVenues);
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
      final loadedVenues = await _venueRepository.getVenues();
      Map<String, int> categoryMapping = {};

      // Tambahkan pengecekan null dan empty
      if (loadedVenues.isEmpty) {
        print('No venues loaded for categories');
        return;
      }

      for (var venue in loadedVenues) {
        if (venue.category?.name != null && venue.category?.id != null) {
          categoryMapping[venue.category!.name!] = venue.category!.id!;
        }
      }

      // Tambahkan pengecekan sebelum assign
      if (categoryMapping.isNotEmpty) {
        categoryMap.assignAll(categoryMapping);
        categories.assignAll(categoryMapping.keys.toList());
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Tambahkan penanganan error
      hasError.value = true;
      errorMessage.value = 'Failed to load categories. Please try again.';
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
    await loadVenues();
  }

  void goToVenueDetails(VenueModel venue) {
    if (venue.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {'venueId': venue.id});
    } else {
      Get.snackbar('Error', 'Cannot open venue details',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
