import 'dart:async';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
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

  // Single day search parameters
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
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

  // Single date selection
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      dateText.value = dateController.text;
      
      // Set default times if not set
      if (startTime.value == null) {
        startTime.value = const TimeOfDay(hour: 8, minute: 0);
      }
      if (endTime.value == null) {
        endTime.value = const TimeOfDay(hour: 22, minute: 0);
      }
    }
  }

  // Time selection
  Future<void> selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: startTime.value ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(          
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validasi waktu operasional (8:00 - 22:00)
      if (_isTimeWithinOperatingHours(picked)) {
        startTime.value = picked;
        
        // Jika waktu mulai lebih besar dari waktu akhir, sesuaikan waktu akhir
        if (endTime.value != null) {
          final startMinutes = picked.hour * 60 + picked.minute;
          final endMinutes = endTime.value!.hour * 60 + endTime.value!.minute;
          
          if (startMinutes >= endMinutes) {
            // Set waktu akhir 1 jam setelah waktu mulai atau 22:00 (mana yang lebih awal)
            final newEndHour = picked.hour + 1 > 22 ? 22 : picked.hour + 1;
            endTime.value = TimeOfDay(hour: newEndHour, minute: picked.minute);
            
            CustomSnackbar.show(
              context: Get.context!,
              message: LocalizationHelper.tr(LocaleKeys.common_success),
              type: SnackbarType.info,
              autoClear: true,
              enableDebounce: true,
            );
          }
        } else {
          // Jika waktu akhir belum dipilih, set default 2 jam setelah waktu mulai atau 22:00 (mana yang lebih awal)
          final newEndHour = picked.hour + 2 > 22 ? 22 : picked.hour + 2;
          endTime.value = TimeOfDay(hour: newEndHour, minute: picked.minute);
        }
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: LocalizationHelper.tr(LocaleKeys.common_error),
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false,
        );
      }
    }
  }

  Future<void> selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: endTime.value ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(          
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validasi waktu operasional (8:00 - 22:00)
      if (_isTimeWithinOperatingHours(picked)) {
        // Validasi waktu akhir harus setelah waktu mulai
        if (startTime.value != null) {
          final startMinutes = startTime.value!.hour * 60 + startTime.value!.minute;
          final endMinutes = picked.hour * 60 + picked.minute;
          
          if (endMinutes <= startMinutes) {
            CustomSnackbar.show(
              context: Get.context!,
              message: LocalizationHelper.tr(LocaleKeys.common_error),
              type: SnackbarType.error,
              autoClear: true,
              enableDebounce: false,
            );
            return;
          }
        }
        
        endTime.value = picked;
      } else {
        CustomSnackbar.show(
          context: Get.context!,
          message: LocalizationHelper.tr(LocaleKeys.common_error),
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false,
        );
      }
    }
  }
  
  // Helper method untuk validasi waktu operasional
  bool _isTimeWithinOperatingHours(TimeOfDay time) {
    final minutes = time.hour * 60 + time.minute;
    final openingMinutes = 8 * 60; // 08:00
    final closingMinutes = 22 * 60; // 22:00
    
    return minutes >= openingMinutes && minutes <= closingMinutes;
  }

  // Helper method untuk memformat informasi waktu
  String _formatTimeInfo() {
    String timeInfo = '';
    
    // Format tanggal
    if (selectedDate.value != null) {
      timeInfo += '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}';
      
      // Tambahkan informasi waktu
      if (startTime.value != null && endTime.value != null) {
        timeInfo += ' • ${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')} - '
                  '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}';
      }
    } else if (startTime.value != null && endTime.value != null) {
      // Hanya waktu tanpa tanggal
      timeInfo = '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')} - '
               '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}';
    }
    
    return timeInfo;
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

  // Capacity with safety checks
  void onCapacityInputChanged(String value) {
    try {
      if (value.isEmpty) {
        maxCapacity.value = 0;
        capacityText.value = '';
        return;
      }

      // Remove any non-numeric characters as safety measure
      final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanValue.isEmpty) {
        maxCapacity.value = 0;
        capacityText.value = '';
        return;
      }

      final intValue = int.tryParse(cleanValue);
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
            message: LocalizationHelper.tr(LocaleKeys.errors_capacityExceeded),
            type: SnackbarType.warning,
            autoClear: true,
            enableDebounce: true);
      } else {
        // Invalid input, reset to safe value
        maxCapacity.value = 0;
        capacityText.value = '';
      }
    } catch (e) {
      print('Error in onCapacityInputChanged: $e');
      // Safe fallback
      maxCapacity.value = 0;
      capacityText.value = '';
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

  // Advanced search - now flexible, no mandatory fields
  Future<void> performAdvancedSearch() async {
    // Prevent multiple simultaneous requests
    if (isLoading.value) {
      print('Search already in progress, ignoring duplicate request');
      return;
    }
    
    // Validasi minimal ada satu parameter search
    if (activityText.value.isEmpty && 
        locationText.value.isEmpty && 
        capacityText.value.isEmpty && 
        selectedDate.value == null) {
      CustomSnackbar.show(
          context: Get.context!,
          message: LocalizationHelper.tr(LocaleKeys.search_fillAtLeastOne),
          type: SnackbarType.warning,
          autoClear: true,
          enableDebounce: false);
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

      // Date and time filters for single day
      if (selectedDate.value != null) {
        DateTime startDateTime = selectedDate.value!;
        DateTime endDateTime = selectedDate.value!;
        
        // Apply start time if provided
        if (startTime.value != null) {
          startDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            startTime.value!.hour,
            startTime.value!.minute,
          );
        } else {
          // Default start time 08:00
          startDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            8,
            0,
          );
          startTime.value = const TimeOfDay(hour: 8, minute: 0);
        }
        
        // Apply end time if provided
        if (endTime.value != null) {
          endDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            endTime.value!.hour,
            endTime.value!.minute,
          );
        } else {
          // Default end time 22:00
          endDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            22,
            0,
          );
          endTime.value = const TimeOfDay(hour: 22, minute: 0);
        }
        
        searchParams['start_datetime'] = startDateTime.toIso8601String();
        searchParams['end_datetime'] = endDateTime.toIso8601String();
      }

      final results = await _venueRepository.searchAvailableVenues(searchParams)
          .timeout(
            const Duration(seconds: 30), 
            onTimeout: () {
              throw TimeoutException('Search request timed out', const Duration(seconds: 30));
            },
          );
      
      if (results.isNotEmpty) {
        searchResults.assignAll(results);
      } else {
        searchResults.clear();
      }

      // Buat ringkasan parameter pencarian untuk ditampilkan
      Map<String, dynamic> searchSummary = {
        'activity': activityText.value.isNotEmpty ? activityText.value : null,
        'location': locationText.value.isNotEmpty ? locationText.value : null,
        'capacity': capacityText.value.isNotEmpty ? capacityText.value : null,
        'date': dateText.value.isNotEmpty ? dateText.value : null,
        'startTime': startTime.value != null
            ? '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        'endTime': endTime.value != null
            ? '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}'
            : null,
        'timeInfo': _formatTimeInfo(),
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

  // Individual clear methods
  void clearActivity() {
    activityController.clear();
    activityText.value = '';
    selectedActivityId.value = 0;
  }

  void clearLocation() {
    locationController.clear();
    locationText.value = '';
    selectedCityId.value = 0;
    selectedCity.value = '';
  }

  void clearDate() {
    dateController.clear();
    dateText.value = '';
    selectedDate.value = null;
    startTime.value = null;
    endTime.value = null;
  }

  void clearCapacity() {
    capacityController.clear();
    capacityInputController.clear();
    capacityText.value = '';
    maxCapacity.value = 0;
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
    selectedDate.value = null;
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
