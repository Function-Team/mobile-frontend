import 'package:get/get.dart';

class PromoController extends GetxController {
  // Current page index for the carousel
  final RxInt currentIndex = 0.obs;
  
  // List of promo images (you can replace these with your actual promo images)
  final List<String> promoImages = [
    'https://t4.ftcdn.net/jpg/01/15/04/39/360_F_115043913_g00I2WhOKYresf7JId9GTTnNy50FBDRi.jpg',
    'https://img.freepik.com/free-vector/special-offer-creative-sale-banner-design_1017-16284.jpg',
    'https://img.freepik.com/free-vector/gradient-sale-background_23-2149050986.jpg',
  ];
  
  // Method to update the current index when carousel page changes
  void updateIndex(int index) {
    currentIndex.value = index;
  }
}