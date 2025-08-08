import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';

class FullscreenImageGallery extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullscreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  _FullscreenImageGalleryState createState() => _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState extends State<FullscreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'No Images Available',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Text(
            'No images to display',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                'Image ${_currentIndex + 1} of ${widget.images.length}',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = widget.images[index];
              final imageUrl = image?.imageUrl ?? image?.toString() ?? '';
              
              return GestureDetector(
                onTap: _toggleControls,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, 
                                      size: 48, 
                                      color: Colors.white60
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Failed to load image",
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported,
                                    size: 48, color: Colors.white60),
                                SizedBox(height: 8),
                                Text(
                                  "No image available",
                                  style: TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          
          // Thumbnail gallery at the bottom
          if (_showControls && widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final image = widget.images[index];
                    // Perbaikan di sini - pastikan kita mendapatkan URL gambar dengan benar
                    String? imageUrl;
                    
                    // Cek apakah image adalah PictureModel
                    if (image is PictureModel) {
                      imageUrl = image.imageUrl;
                    } else if (image != null && image.imageUrl != null) {
                      // Jika objek memiliki properti imageUrl langsung
                      imageUrl = image.imageUrl;
                    } else if (image is String) {
                      // Jika image adalah string URL langsung
                      imageUrl = image;
                    }
                    
                    // Pastikan imageUrl tidak null
                    final url = imageUrl ?? '';
                    
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: url.isNotEmpty
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white60,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white60,
                                  size: 24,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}