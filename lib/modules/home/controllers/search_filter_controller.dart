import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class SearchFilterController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();

  // Controllers
  final activityController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final dateController = TextEditingController();
  final searchQueryController = TextEditingController();
  final capacityInputController = TextEditingController();

  // Tambahkan variabel Rx untuk melacak nilai field
  final RxString activityText = ''.obs;
  final RxString locationText = ''.obs;
  final RxString capacityText = ''.obs;
  final RxString dateText = ''.obs;

  // Observable state lainnya tetap sama
  final RxList<VenueModel> searchResults = <VenueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Enhanced search parameters for multi-day support
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);
  final RxInt selectedCityId = 0.obs;
  final RxInt selectedCategoryId = 0.obs;
  final RxInt selectedActivityId = 0.obs;
  final RxInt maxCapacity = 0.obs;
  final RxString selectedCity = ''.obs;

  // Consistent data structure for cities and activities
  final RxList<CityModel> citiesData = <CityModel>[].obs;
  final RxList<CityModel> filteredCities = <CityModel>[].obs;
  final RxList<ActivityModel> activitiesData = <ActivityModel>[].obs;
  final RxList<CategoryModel> categoriesData = <CategoryModel>[].obs;

  final RxString citySearchQuery = ''.obs;

  // Category filtering state
  final RxString selectedCategory = ''.obs;
  final RxMap<String, int> categoryMap = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Inisialisasi nilai Rx dari controller
    activityText.value = activityController.text;
    locationText.value = locationController.text;
    capacityText.value = capacityController.text;
    dateText.value = dateController.text;

    loadInitialData();
  }

  // Load cities and activities data
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Load cities and activities concurrently
      final results = await Future.wait([
        _venueRepository.getCities(),
        _venueRepository.getActivities(),
        _venueRepository.getCategories(),
      ]);

      citiesData.assignAll(results[0] as List<CityModel>);
      filteredCities.assignAll(results[0] as List<CityModel>);
      activitiesData.assignAll(results[1] as List<ActivityModel>);
      final categories = results[2] as List<CategoryModel>;
      // Store categories if needed for search
      print('✅ Loaded ${categories.length} categories');
      for (var category in categories) {
        print('   - ${category.name} (ID: ${category.id})');
      }
    } catch (e) {
      print('Error loading initial data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Date range selection
  Future<void> selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;

      // Update the UI text properly
      if (picked.start == picked.end) {
        dateController.text =
            '${picked.start.day}/${picked.start.month}/${picked.start.year}';
      } else {
        dateController.text =
            '${picked.start.day}/${picked.start.month} - ${picked.end.day}/${picked.end.month}';
      }

      // Update Rx variable
      dateText.value = dateController.text;
    }
  }

  // Time selection
  Future<void> selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: startTime.value ?? TimeOfDay.now(),
    );

    if (picked != null) {
      startTime.value = picked;
    }
  }

  Future<void> selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: endTime.value ?? TimeOfDay.now(),
    );

    if (picked != null) {
      endTime.value = picked;
    }
  }

  // City selection with search
  void showCityPicker() {
    citySearchQuery.value = '';
    filteredCities.assignAll(citiesData);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'Pilih Kota',
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Cari kota...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                citySearchQuery.value = value;
                if (value.isEmpty) {
                  filteredCities.assignAll(citiesData);
                } else {
                  filteredCities.assignAll(
                    citiesData
                        .where((city) => (city.name ?? '')
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return ListTile(
                        title: Text(city.name ?? 'Unknown City'),
                        // Tambahkan update untuk locationText.value saat kota dipilih
                        onTap: () {
                          selectedCity.value = city.name ?? '';
                          selectedCityId.value = city.id ?? 0;
                          locationController.text = city.name ?? '';
                          locationText.value = locationController.text;
                          Get.back();
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Activity picker
  void showActivityPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'Pilih Aktivitas',
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: activitiesData.length,
                    itemBuilder: (context, index) {
                      final activity = activitiesData[index];
                      return ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(activity.name ?? 'Unknown Activity'),
                        // Tambahkan update untuk activityText.value saat aktivitas dipilih
                        onTap: () {
                          selectedActivityId.value = activity.id ?? 0;
                          activityController.text = activity.name ?? '';
                          activityText.value = activityController.text;
                          Get.back();
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Capacity
  void onCapacityInputChanged(String value) {
    if (value.isEmpty) {
      maxCapacity.value = 0;
      capacityText.value = '';
      return;
    }

    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= 0 && intValue <= 1000) {
      maxCapacity.value = intValue;
      capacityText.value = '$intValue orang';
    } else if (intValue != null && intValue > 1000) {
      // Auto-correct to max value
      maxCapacity.value = 1000;
      capacityInputController.text = '1000';
      capacityText.value = '1000 orang';

      // Show feedback
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Maksimal 1000 orang',
          type: SnackbarType.warning);
    }
  }

  void incrementCapacity() {
    int currentValue = maxCapacity.value;
    if (currentValue < 1000) {
      currentValue += 1;
      maxCapacity.value = currentValue;
      capacityInputController.text = currentValue.toString();
      capacityText.value = '$currentValue orang';
    }
  }

  void decrementCapacity() {
    int currentValue = maxCapacity.value;
    if (currentValue > 0) {
      currentValue -= 1;
      maxCapacity.value = currentValue;
      capacityInputController.text =
          currentValue == 0 ? '' : currentValue.toString();
      capacityText.value = currentValue == 0 ? '' : '$currentValue orang';
    }
  }

  // Navigation methods
  void goToSearchActivity() async {
    final result = await Get.toNamed(MyRoutes.searchActivity);
    if (result != null && result is Map<String, dynamic>) {
      if (result['type'] == 'activity' && result['activityId'] != null) {
        selectedActivityId.value = result['activityId'];
        activityController.text = result['searchQuery'] ?? '';
        activityText.value = activityController.text;
      }
      // Handle venue selection
      else if (result['type'] == 'venue' && result['venueId'] != null) {
        // Set venue name in activity field for search
        activityController.text = result['searchQuery'] ?? '';
        activityText.value = activityController.text;
        // You can also store venue ID if needed
        // selectedVenueId.value = result['venueId'];
      }
      // Handle general search query
      else if (result['type'] == 'search') {
        activityController.text = result['searchQuery'] ?? '';
        activityText.value = activityController.text;
      }
    }
  }

  void goToSearchLocation() async {
    final result = await Get.toNamed(MyRoutes.searchLocation);
    if (result != null && result is String && result.isNotEmpty) {
      locationController.text = result;
    }
  }

  void goToSearchResults() {
    Get.toNamed(MyRoutes.venueList, arguments: {
      'searchResults': searchResults.value,
      'isSearchResult': true,
    });
  }

  // Advanced search
  Future<void> performAdvancedSearch() async {
    // Validasi field wajib
    if (activityText.value.isEmpty) {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Silakan pilih aktivitas atau tempat terlebih dahulu',
          type: SnackbarType.error);
      return;
    }

    if (locationText.value.isEmpty) {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Silakan pilih lokasi terlebih dahulu',
          type: SnackbarType.error);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      Map<String, dynamic> searchParams = {};

      // City filter
      if (selectedCityId.value > 0) {
        searchParams['city_id'] = selectedCityId.value;
      }

      // Activity filter
      if (selectedActivityId.value > 0) {
        searchParams['activity_id'] = selectedActivityId.value;
        print(
            'DEBUG: Sending activity_id: ${selectedActivityId.value}'); // Tambahkan ini
      }
      // Tambahkan parameter search jika tidak ada activity_id yang dipilih
      // Ini akan menangani kasus pencarian berdasarkan nama venue/place
      else if (activityText.value.isNotEmpty) {
        searchParams['search'] = activityText.value;
      }

      // Capacity filter
      if (maxCapacity.value > 0) {
        searchParams['max_capacity'] = maxCapacity.value;
      }

      // Date and time filters
      if (startDate.value != null) {
        searchParams['start_date'] =
            startDate.value!.toIso8601String().split('T')[0];
      }

      if (endDate.value != null) {
        searchParams['end_date'] =
            endDate.value!.toIso8601String().split('T')[0];
      }

      if (startTime.value != null) {
        searchParams['start_time'] =
            '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}:00';
      }

      if (endTime.value != null) {
        searchParams['end_time'] =
            '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}:00';
      }

      final results =
          await _venueRepository.searchAvailableVenues(searchParams);
      searchResults.assignAll(results);

      // Buat ringkasan parameter pencarian untuk ditampilkan
      Map<String, dynamic> searchSummary = {
        'activity': activityText.value,
        'location': locationText.value,
        'capacity': capacityText.value,
        'date': dateText.value,
        'startTime': startTime.value != null
            ? '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        'endTime': endTime.value != null
            ? '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
      };

      // Navigate to results dengan parameter lengkap
      // Di dalam performAdvancedSearch()
      Get.toNamed(MyRoutes.venueList, arguments: {
        'searchResults': results,
        'isSearchResult': true,
        'searchSummary': searchSummary,
        'searchQuery': activityText.value,
        'originalSearchParams': searchParams, // Tambahkan ini
      });
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Search failed: ${e.toString()}';
      print('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all search filters
  void clearAllFilters() {
    activityController.clear();
    locationController.clear();
    capacityController.clear();
    dateController.clear();
    searchQueryController.clear();

    // Update Rx variables
    activityText.value = '';
    locationText.value = '';
    capacityText.value = '';
    dateText.value = '';
    startDate.value = null;
    endDate.value = null;
    startTime.value = null;
    endTime.value = null;
    selectedCityId.value = 0;
    selectedCategoryId.value = 0;
    selectedActivityId.value = 0;
    maxCapacity.value = 0;
    capacityInputController.clear();
    capacityText.value = '';
    selectedCity.value = '';
    searchResults.clear();
  }

  @override
  void onClose() {
    activityController.dispose();
    locationController.dispose();
    capacityInputController.dispose();
    dateController.dispose();
    searchQueryController.dispose();
    super.onClose();
  }
}
