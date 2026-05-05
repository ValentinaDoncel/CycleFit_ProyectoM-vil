import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isTablet => screenWidth >= 700;

  double get pageHorizontalPadding => isTablet ? 32 : 20;

  double get maxContentWidth => isTablet ? 720 : screenWidth;
}
