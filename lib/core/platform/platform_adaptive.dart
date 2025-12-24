// Platform utilities - barrel exports
// Compatible re-exports for backward compatibility

export 'platform_core.dart';
export 'platform_haptics.dart';
export 'adaptive_bottom_sheet.dart';
export 'adaptive_dialogs.dart';
export 'adaptive_action_sheet.dart';

// Re-export for backward compatibility
// Deprecated: Use PlatformHaptics directly
import 'platform_core.dart' as core;
import 'platform_haptics.dart' as haptics;

@Deprecated('Use PlatformHaptics directly')
class PlatformAdaptive {
  static bool get isIOS => core.PlatformAdaptive.isIOS;
  static bool get isAndroid => core.PlatformAdaptive.isAndroid;
  static get scrollPhysics => core.PlatformAdaptive.scrollPhysics;

  static pageRoute<T>({
    required builder,
    settings,
    bool fullscreenDialog = false,
  }) => core.PlatformAdaptive.pageRoute<T>(
    builder: builder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );

  static void hapticLight() => haptics.PlatformHaptics.light();
  static void hapticMedium() => haptics.PlatformHaptics.medium();
  static void hapticHeavy() => haptics.PlatformHaptics.heavy();
  static void hapticSelection() => haptics.PlatformHaptics.selection();
  static void hapticSuccess() => haptics.PlatformHaptics.success();
  static void hapticError() => haptics.PlatformHaptics.error();
}
