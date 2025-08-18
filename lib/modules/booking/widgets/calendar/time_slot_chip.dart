import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';

class TimeSlotChip extends StatelessWidget {
  final DetailedTimeSlot slot;
  final bool isSelected;
  final bool isFirstSelected;
  final bool isLastSelected;
  final bool isInPreviewRange;
  final bool isConnectableFromOtherCategory;
  final bool isDisabledByConstraint;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapCancel;

  const TimeSlotChip({
    Key? key,
    required this.slot,
    required this.isSelected,
    required this.isFirstSelected,
    required this.isLastSelected,
    required this.isInPreviewRange,
    required this.isConnectableFromOtherCategory,
    required this.isDisabledByConstraint,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.available;
    
    // Determine colors and styling
    final styling = _getSlotStyling();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: (isAvailable && !isDisabledByConstraint) ? onTap : null,
        onTapDown: (isAvailable && !isDisabledByConstraint) ? (_) => onTapDown?.call() : null,
        onTapCancel: onTapCancel,
        child: InkWell(
          onTap: (isAvailable && !isDisabledByConstraint) ? onTap : null,
          borderRadius: styling.borderRadius,
          splashColor: isAvailable 
              ? (isSelected 
                  ? Colors.white.withOpacity(0.2) 
                  : Get.theme.primaryColor.withOpacity(0.1))
              : null,
          highlightColor: isAvailable 
              ? (isSelected 
                  ? Colors.white.withOpacity(0.1) 
                  : Get.theme.primaryColor.withOpacity(0.05))
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: styling.backgroundColor,
              borderRadius: styling.borderRadius,
              border: Border.all(
                color: styling.borderColor,
                width: isSelected ? 2.5 : isInPreviewRange ? 2.0 : 1.5,
              ),
              boxShadow: styling.boxShadow,
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${slot.start}-${slot.end}',
                          style: TextStyle(
                            color: styling.textColor,
                            fontSize: 11, // Increased from 9 for better readability
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(height: 0.5),
                        Flexible(
                          child: Icon(
                            Icons.block,
                            color: styling.textColor,
                            size: 8,
                          ),
                        ),
                      ] else if (isDisabledByConstraint) ...[
                        const SizedBox(height: 0.5),
                        Flexible(
                          child: Icon(
                            Icons.link_off,
                            color: styling.textColor,
                            size: 8,
                          ),
                        ),
                      ] else if (isSelected) ...[
                        const SizedBox(height: 0.5),
                        Flexible(
                          child: Icon(
                            isFirstSelected && isLastSelected 
                                ? Icons.check_circle 
                                : isFirstSelected 
                                    ? Icons.play_arrow
                                    : isLastSelected 
                                        ? Icons.stop
                                        : Icons.remove,
                            color: styling.textColor,
                            size: 8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                  
                // Special marking for first/last selected
                if (isSelected && (isFirstSelected || isLastSelected))
                  Positioned(
                    top: 1,
                    left: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFirstSelected ? Icons.start : Icons.stop,
                        color: Get.theme.primaryColor,
                        size: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SlotStyling _getSlotStyling() {
    final isAvailable = slot.available;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    BorderRadius borderRadius;
    List<BoxShadow> boxShadow = [];

    if (!isAvailable) {
      // Booked/Unavailable - Red
      backgroundColor = Colors.red[100]!;
      borderColor = Colors.red[300]!;
      textColor = Colors.red[600]!;
      borderRadius = BorderRadius.circular(10);
    } else if (isDisabledByConstraint) {
      // Available but disabled by continuity constraint - Gray
      backgroundColor = Colors.grey[200]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
      borderRadius = BorderRadius.circular(10);
    } else if (isSelected) {
      // Selected - Blue/Primary with range indication
      backgroundColor = Get.theme.primaryColor;
      borderColor = Get.theme.primaryColor;
      textColor = Colors.white;
      
      // Create connected look for range selection
      if (isFirstSelected && !isLastSelected) {
        // First slot in range - rounded left only
        borderRadius = BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        );
      } else if (isLastSelected && !isFirstSelected) {
        // Last slot in range - rounded right only
        borderRadius = BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        );
      } else if (isFirstSelected && isLastSelected) {
        // Single slot selection - fully rounded
        borderRadius = BorderRadius.circular(10);
      } else {
        // Middle slot in range - not rounded
        borderRadius = BorderRadius.circular(4);
      }

      boxShadow = [
        BoxShadow(
          color: Get.theme.primaryColor.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isInPreviewRange) {
      // Preview range - lighter blue with prominent border
      backgroundColor = Get.theme.primaryColor.withOpacity(0.15);
      borderColor = Get.theme.primaryColor.withOpacity(0.8);
      textColor = Get.theme.primaryColor.withOpacity(0.9);
      borderRadius = BorderRadius.circular(8);
      
      boxShadow = [
        BoxShadow(
          color: Get.theme.primaryColor.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];
    } else if (isConnectableFromOtherCategory) {
      // Connectable from other category - Purple/violet theme
      backgroundColor = Colors.purple[50]!;
      borderColor = Colors.purple[300]!;
      textColor = Colors.purple[700]!;
      borderRadius = BorderRadius.circular(10);
    } else {
      // Available - Green
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[300]!;
      textColor = Colors.green[700]!;
      borderRadius = BorderRadius.circular(10);
      
      boxShadow = [
        BoxShadow(
          color: Colors.green.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }

    return SlotStyling(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textColor: textColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    );
  }
}

class SlotStyling {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;

  SlotStyling({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.borderRadius,
    required this.boxShadow,
  });
}