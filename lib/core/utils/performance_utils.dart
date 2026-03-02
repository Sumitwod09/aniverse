import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

/// Utility class for performance optimizations
class PerformanceUtils {
  /// Debounce function calls
  static VoidCallback debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    DateTime? lastCall;
    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) > delay) {
        lastCall = now;
        callback();
      }
    };
  }

  /// Throttle function calls
  static Function throttle(
    Function callback, {
    Duration delay = const Duration(milliseconds: 1000),
  }) {
    bool isThrottled = false;
    return () {
      if (!isThrottled) {
        isThrottled = true;
        callback();
        Future.delayed(delay, () => isThrottled = false);
      }
    };
  }

  /// Run expensive operation on compute isolate
  static Future<T> runOnIsolate<T>(
    ComputeCallback<dynamic, T> callback,
    dynamic message,
  ) async {
    return await compute(callback, message);
  }
}

/// Image cache configuration
class ImageCacheConfig {
  static const int maxCacheSize = 100; // Maximum number of images
  static const Duration cacheDuration = Duration(hours: 24);
  
  static void configure() {
    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
  }
}

/// Memory management utilities
class MemoryUtils {
  /// Clear image cache when memory is low
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Request garbage collection (best effort)
  static void requestGC() {
    // Trigger garbage collection hint
    final list = List.filled(1000, 0);
    list.clear();
  }
}
