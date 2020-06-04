import 'dart:ui';

extension ColorExtension on Color {
  String toRgbString() {
    return "${this.red},${this.green},${this.blue}";
  }

  Color fromRgbString(String colorString) {
    List<int> nums = colorString.split(',').map((num) => int.parse(num)).toList();
    return Color.fromARGB(255, nums[0], nums[1], nums[2]);
  }
}
