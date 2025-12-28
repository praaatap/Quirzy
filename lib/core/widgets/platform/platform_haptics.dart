import 'dart:io';
import 'package:flutter/services.dart';

/// Platform-adaptive haptic feedback utilities
class PlatformHaptics {
  static bool get isIOS => Platform.isIOS;

  /// Light haptic feedback
  static void light() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// Medium haptic feedback
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success haptic feedback
  static void success() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  /// Error haptic feedback
  static void error() {
    HapticFeedback.heavyImpact();
  }
}
