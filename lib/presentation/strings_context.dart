import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../domain/app_strings.dart';
import 'settings_controller.dart';

extension StringsContext on BuildContext {
  /// Chữ giao diện theo ngôn ngữ hiện tại; chỉ dùng trong build (tự vẽ lại khi đổi ngôn ngữ).
  AppStrings get strings => Provider.of<SettingsController>(this).strings;

  /// Dùng trong callback (onPressed, sau await...), nơi không được lắng nghe.
  AppStrings get stringsNow => Provider.of<SettingsController>(this, listen: false).strings;
}
