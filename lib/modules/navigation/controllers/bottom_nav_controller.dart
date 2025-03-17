import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController{
  final RxInt currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
}