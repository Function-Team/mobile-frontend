import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult({required this.isValid, required this.message});

  factory ValidationResult.success([String message = '']) {
    return ValidationResult(isValid: true, message: message);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult(isValid: false, message: message);
  }
}

class BookingValidationService extends GetxService {
  // Future: untuk localization
  // final LocalizationController _localization = Get.find();

  // =============================================
  // GUEST INFORMATION VALIDATION
  // =============================================

  /// Validate guest name
  ValidationResult validateGuestName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return ValidationResult.error('Nama tamu wajib diisi');
    }

    if (trimmedName.length < 2) {
      return ValidationResult.error('Nama minimal 2 karakter');
    }

    if (trimmedName.length > 50) {
      return ValidationResult.error('Nama maksimal 50 karakter');
    }

    // Check for valid characters (letters, spaces, some special chars)
    return ValidationResult.success();
  }

  /// Validate guest email
  ValidationResult validateGuestEmail(String email) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      return ValidationResult.error('Email wajib diisi');
    }

    // Use GetUtils for consistency + additional checks
    if (!GetUtils.isEmail(trimmedEmail)) {
      return ValidationResult.error('Format email tidak valid');
    }

    if (trimmedEmail.length > 100) {
      return ValidationResult.error('Email maksimal 100 karakter');
    }

    return ValidationResult.success();
  }

  /// Validate guest phone (Indonesian format)
  ValidationResult validateGuestPhone(String phone) {
    final trimmedPhone = phone.trim();

    if (trimmedPhone.isEmpty) {
      return ValidationResult.error('Nomor telepon wajib diisi');
    }

    // Remove all non-digits for validation
    final digitsOnly = trimmedPhone.replaceAll(RegExp(r'[^\d]'), '');

    // Indonesian phone number patterns (following BE validation)
    final validPatterns = [
      RegExp(r'^08\d{8,11}$'), // 08xx-xxxx-xxxx (10-13 digits)
      RegExp(r'^628\d{8,11}$'), // 628xx-xxxx-xxxx (12-15 digits)
    ];

    bool isValidPattern =
        validPatterns.any((pattern) => pattern.hasMatch(digitsOnly));

    if (!isValidPattern) {
      return ValidationResult.error(
          'Format nomor tidak valid (gunakan 08xx atau 628xx)');
    }

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return ValidationResult.error('Nomor telepon harus 10-15 digit');
    }

    return ValidationResult.success();
  }

  /// Validate all guest information at once
  ValidationResult validateAllGuestInfo({
    required String name,
    required String email,
    required String phone,
  }) {
    // Check name first
    final nameResult = validateGuestName(name);
    if (!nameResult.isValid) return nameResult;

    // Check email
    final emailResult = validateGuestEmail(email);
    if (!emailResult.isValid) return emailResult;

    // Check phone
    final phoneResult = validateGuestPhone(phone);
    if (!phoneResult.isValid) return phoneResult;

    return ValidationResult.success('Informasi tamu valid');
  }

  // =============================================
  // CAPACITY VALIDATION
  // =============================================

  /// Validate guest capacity
  ValidationResult validateCapacity(String capacityText,
      [int? venueMaxCapacity]) {
    if (capacityText.trim().isEmpty) {
      return ValidationResult.error('Jumlah tamu wajib diisi');
    }

    int? capacity;
    try {
      capacity = int.parse(capacityText.trim());
    } catch (e) {
      return ValidationResult.error('Masukkan angka yang valid');
    }

    // Allow 0 input but show validation error (this prevents form submission)
    if (capacity <= 0) {
      return ValidationResult.error('Minimal harus ada 1 tamu');
    }

    // Allow input above venue capacity but show validation error
    if (venueMaxCapacity != null && capacity > venueMaxCapacity) {
      return ValidationResult.error(
          'Melebihi kapasitas venue ($venueMaxCapacity orang)');
    }

    return ValidationResult.success();
  }
  // =============================================
  // DATE VALIDATION
  // =============================================

  /// Validate booking date
  ValidationResult validateDate(DateTime? date) {
    if (date == null) {
      return ValidationResult.error('Pilih tanggal booking terlebih dahulu');
    }

    final today = DateTime.now();
    final selectedDateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (selectedDateOnly.isBefore(todayOnly)) {
      return ValidationResult.error(
          'Tidak dapat booking untuk tanggal yang sudah lewat');
    }

    // Check if date is too far in future (business rule)
    final maxFutureDate = today.add(Duration(days: 365));
    if (selectedDateOnly.isAfter(maxFutureDate)) {
      return ValidationResult.error('Booking maksimal 1 tahun ke depan');
    }

    return ValidationResult.success();
  }

  // =============================================
  // TIME VALIDATION
  // =============================================

  /// Validate time slot
  ValidationResult validateTimeSlot({
    required DateTime? date,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
  }) {
    // First check if date is valid
    final dateResult = validateDate(date);
    if (!dateResult.isValid) return dateResult;

    if (startTime == null || endTime == null) {
      return ValidationResult.error('Pilih waktu mulai dan selesai');
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes >= endMinutes) {
      return ValidationResult.error('Waktu selesai harus setelah waktu mulai');
    }

    final durationMinutes = endMinutes - startMinutes;

    // Minimum 1 hour (following BE business rule)
    if (durationMinutes < 60) {
      return ValidationResult.error('Durasi booking minimal 1 jam');
    }

    // Maximum 14 hours (based on venue operating hours 8AM-10PM)
    if (durationMinutes > 14 * 60) {
      return ValidationResult.error('Durasi booking maksimal 14 jam per hari');
    }

    // 30-minute increments check (following BE pattern)
    if (startTime.minute % 30 != 0 || endTime.minute % 30 != 0) {
      return ValidationResult.error(
          'Gunakan waktu dalam kelipatan 30 menit (09:00, 09:30, dst)');
    }

    return ValidationResult.success();
  }

  // =============================================
  // COMPREHENSIVE FORM VALIDATION
  // =============================================

  /// Validate entire booking form
  /// Validate entire booking form with specific field error messages
  ValidationResult validateBookingFormWithSpecificError({
    required DateTime? selectedDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String capacityText,
    int? venueMaxCapacity,
  }) {
    // Check each field in order and return first error found

    // 1. Date validation
    final dateResult = validateDate(selectedDate);
    if (!dateResult.isValid) return dateResult;

    // 2. Time validation
    final timeResult = validateTimeSlot(
      date: selectedDate,
      startTime: startTime,
      endTime: endTime,
    );
    if (!timeResult.isValid) return timeResult;

    // 3. Guest name validation
    final nameResult = validateGuestName(guestName);
    if (!nameResult.isValid) return nameResult;

    // 4. Guest email validation
    final emailResult = validateGuestEmail(guestEmail);
    if (!emailResult.isValid) return emailResult;

    // 5. Guest phone validation
    final phoneResult = validateGuestPhone(guestPhone);
    if (!phoneResult.isValid) return phoneResult;

    // 6. Capacity validation
    final capacityResult = validateCapacity(capacityText, venueMaxCapacity);
    if (!capacityResult.isValid) return capacityResult;

    return ValidationResult.success('Form booking valid dan siap diproses');
  }

  /// Validate entire booking form (original method - kept for compatibility)
  ValidationResult validateBookingForm({
    required DateTime? selectedDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String capacityText,
    int? venueMaxCapacity,
  }) {
    return validateBookingFormWithSpecificError(
      selectedDate: selectedDate,
      startTime: startTime,
      endTime: endTime,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      capacityText: capacityText,
      venueMaxCapacity: venueMaxCapacity,
    );
  }
  // =============================================
  // UTILITY METHODS
  // =============================================

  /// Get form completion status
  Map<String, dynamic> getFormCompletionStatus({
    required DateTime? selectedDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String capacityText,
    int? venueMaxCapacity,
  }) {
    final validations = {
      'date': validateDate(selectedDate),
      'time': validateTimeSlot(
          date: selectedDate, startTime: startTime, endTime: endTime),
      'guest': validateAllGuestInfo(
          name: guestName, email: guestEmail, phone: guestPhone),
      'capacity': validateCapacity(capacityText, venueMaxCapacity),
    };

    final validCount = validations.values.where((v) => v.isValid).length;
    final totalCount = validations.length;

    final incompleteFields = <String>[];
    validations.forEach((key, result) {
      if (!result.isValid) {
        switch (key) {
          case 'date':
            incompleteFields.add('Tanggal');
            break;
          case 'time':
            incompleteFields.add('Waktu');
            break;
          case 'guest':
            incompleteFields.add('Info Tamu');
            break;
          case 'capacity':
            incompleteFields.add('Kapasitas');
            break;
        }
      }
    });

    return {
      'isComplete': validCount == totalCount,
      'completionPercentage': validCount / totalCount,
      'validCount': validCount,
      'totalCount': totalCount,
      'incompleteFields': incompleteFields,
      'validations': validations,
    };
  }

  /// Parse server validation errors (helper for controller)
  Map<String, String> parseServerErrors(dynamic error) {
    final errors = <String, String>{};

    if (error is Map<String, dynamic>) {
      error.forEach((field, message) {
        switch (field.toLowerCase()) {
          case 'guest_name':
            errors['name'] = message.toString();
            break;
          case 'guest_email':
            errors['email'] = message.toString();
            break;
          case 'guest_phone':
            errors['phone'] = message.toString();
            break;
          case 'guest_count':
            errors['capacity'] = message.toString();
            break;
          case 'start_datetime':
          case 'end_datetime':
            errors['time'] = message.toString();
            break;
          default:
            errors['general'] = message.toString();
        }
      });
    } else if (error is String) {
      // Handle simple error strings
      if (error.toLowerCase().contains('email')) {
        errors['email'] = error;
      } else if (error.toLowerCase().contains('phone')) {
        errors['phone'] = error;
      } else if (error.toLowerCase().contains('name')) {
        errors['name'] = error;
      } else {
        errors['general'] = error;
      }
    }

    return errors;
  }
}
