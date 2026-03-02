import 'package:flutter/foundation.dart';

/// Firestore service stub — Firebase is not yet configured.
/// This provides a no-op implementation so the rest of the app compiles.
/// Replace with real Firestore calls once Firebase is set up.
class FirestoreService {
  /// Create or update user document (no-op)
  Future<void> createUserDocument(Map<String, dynamic> userData) async {
    debugPrint('[FirestoreService] createUserDocument stub called');
  }

  /// Update user profile (no-op)
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    debugPrint('[FirestoreService] updateUserProfile stub called');
  }

  /// Get user document (returns null)
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    debugPrint('[FirestoreService] getUserDocument stub called');
    return null;
  }

  /// Delete user document (no-op)
  Future<void> deleteUserDocument(String userId) async {
    debugPrint('[FirestoreService] deleteUserDocument stub called');
  }

  /// Add to favorites (no-op)
  Future<void> addToFavorites(String userId, String animeId) async {
    debugPrint('[FirestoreService] addToFavorites stub called');
  }

  /// Remove from favorites (no-op)
  Future<void> removeFromFavorites(String userId, String animeId) async {
    debugPrint('[FirestoreService] removeFromFavorites stub called');
  }

  /// Update preferences (no-op)
  Future<void> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    debugPrint('[FirestoreService] updatePreferences stub called');
  }
}
