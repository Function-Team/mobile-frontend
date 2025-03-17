import 'package:flutter/material.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageWithLoader({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: frame != null ? child : _buildLoadingContainer(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorContainer();
        },
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            'Image not available',
            overflow: TextOverflow.values[0],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
