import 'dart:ui';

import 'package:flutter/material.dart';

extension StringExtension on String {
  Color toColor({defaultColor: Colors.white}) {
    List<int> nums = this.split(',').map((num) => int.parse(num)).toList();

    if (nums.isEmpty || nums.length < 3) {
      return defaultColor;
    }

    return Color.fromARGB(255, nums[0], nums[1], nums[2]);
  }
}
