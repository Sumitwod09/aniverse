import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple auth service without Firebase for now
class AuthService {
  // Guest mode - always true for now
  bool get isGuest => true;
  
  // Simple user model for guest mode
  User get currentUser => User.guest();
  
  // Sign in as guest (always succeeds)
  Future<void> signInAsGuest() async {
    // No-op for guest mode
  }
  
  // Sign out (no-op for guest mode)
  Future<void> signOut() async {
    // No-op for guest mode
  }
}

// Simple user model
class User {
  final String id;
  final String email;
  final String? displayName;
  final bool isGuest;
  
  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.isGuest,
  });
  
  factory User.guest() {
    return User(
      id: 'guest',
      email: 'guest@aniverse.app',
      displayName: 'Guest User',
      isGuest: true,
    );
  }
}

// Auth state
enum AuthStatus {
  initial,
  authenticated,
  guest,
  loading,
  error,
}

// Auth state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  
  AuthState({
    required this.status,
    this.user,
    this.error,
  });
  
  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.guest() => AuthState(
    status: AuthStatus.guest,
    user: User.guest(),
  );
  factory AuthState.authenticated(User user) => AuthState(
    status: AuthStatus.authenticated,
    user: user,
  );
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.error(String error) => AuthState(
    status: AuthStatus.error,
    error: error,
  );
  
  // Helper methods
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
  
  AuthState when({
    AuthState Function()? initial,
    AuthState Function()? authenticated,
    AuthState Function()? guest,
    AuthState Function()? loading,
    AuthState Function(String error)? error,
  }) {
    switch (status) {
      case AuthStatus.initial:
        return initial?.call() ?? this;
      case AuthStatus.authenticated:
        return authenticated?.call() ?? this;
      case AuthStatus.guest:
        return guest?.call() ?? this;
      case AuthStatus.loading:
        return loading?.call() ?? this;
      case AuthStatus.error:
        return error?.call(error.toString() ?? 'Unknown error') ?? this;
    }
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    state = AuthState.loading();
    
    try {
      await _authService.signInAsGuest();
      state = AuthState.guest();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signInAsGuest() async {
    state = AuthState.loading();
    
    try {
      await _authService.signInAsGuest();
      state = AuthState.guest();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signOut() async {
    state = AuthState.loading();
    
    try {
      await _authService.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  // Helper methods
  bool get isAuthenticated => state.isAuthenticated;
  bool get isGuest => state.isGuest;
  User? get user => state.user;
}

// Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

final isGuestProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isGuest;
});
