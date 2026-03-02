import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Collection Reference
  CollectionReference<Map<String, dynamic>> get _usersRef => 
      _firestore.collection('users');

  /// Create or update user document
  Future<void> createUserDocument(User user) async {
    await _usersRef.doc(user.id).set({
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'isGuest': user.isGuest,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'favorites': user.favorites ?? [],
      'preferences': user.preferences ?? {},
    });
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update({
      ...data,
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user document
  Future<User?> getUserDocument(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return User(
      id: data['id'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isGuest: data['isGuest'] as bool?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      favorites: List<String>.from((data['favorites'] as List<dynamic>?) ?? []),
      preferences: Map<String, dynamic>.from((data['preferences'] as Map<dynamic, dynamic>?) ?? {}),
    );
  }

  /// Delete user document
  Future<void> deleteUserDocument(String userId) async {
    await _usersRef.doc(userId).delete();
  }

  /// Add to favorites
  Future<void> addToFavorites(String userId, String animeId) async {
    await _usersRef.doc(userId).update({
      'favorites': FieldValue.arrayUnion([animeId]),
    });
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String userId, String animeId) async {
    await _usersRef.doc(userId).update({
      'favorites': FieldValue.arrayRemove([animeId]),
    });
  }

  /// Update preferences
  Future<void> updatePreferences(String userId, Map<String, dynamic> preferences) async {
    await _usersRef.doc(userId).update({
      'preferences': preferences,
    });
  }

  /// Stream user document
  Stream<User?> streamUserDocument(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return User(
        id: data['id'] as String,
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
        photoUrl: data['photoUrl'] as String?,
        isGuest: data['isGuest'] as bool?,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
        favorites: List<String>.from((data['favorites'] as List<dynamic>?) ?? []),
        preferences: Map<String, dynamic>.from((data['preferences'] as Map<dynamic, dynamic>?) ?? {}),
      );
    });
  }
}
