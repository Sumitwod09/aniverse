# AniVerse - Technical Requirements Document (TRD)

## 1. Architecture Overview

### 1.1 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| Language | Dart | Application logic |
| State Management | Riverpod | Reactive state |
| Local Storage | Hive | Offline data, cache |
| Remote Storage | Firebase Firestore | User data, sync |
| Authentication | Firebase Auth | User authentication |
| HTTP Client | Dio | API requests |
| Video Player | video_player + chewie | Streaming |
| Image Loading | cached_network_image | Image caching |
| PDF/Reader | photo_view | Manga zoom/pan |

### 1.2 Architecture Pattern

**Clean Architecture with Layered Approach:**

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│  (Screens, Widgets, Riverpod Providers) │
├─────────────────────────────────────────┤
│           Domain Layer                   │
│    (Models, Use Cases, Repository)      │
├─────────────────────────────────────────┤
│            Data Layer                    │
│   (Services, APIs, Local Storage)       │
└─────────────────────────────────────────┘
```

---

## 2. Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── constants.dart
│       └── performance_utils.dart
├── data/
│   ├── models/
│   │   ├── anime.dart
│   │   ├── manga.dart
│   │   ├── chapter.dart
│   │   ├── episode.dart
│   │   ├── user.dart
│   │   ├── reading_progress.dart
│   │   └── review.dart
│   ├── services/
│   │   ├── jikan_service.dart
│   │   ├── mangadex_service.dart
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── download_service.dart
│   │   └── reading_progress_service.dart
│   └── providers/
│       ├── anime_providers.dart
│       ├── manga_providers.dart
│       └── auth_providers.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── anime_detail_screen.dart
│   │   ├── manga_detail_screen.dart
│   │   ├── manga_reader_screen.dart
│   │   ├── video_player_screen.dart
│   │   ├── browse_screen.dart
│   │   ├── search_screen.dart
│   │   ├── watchlist_screen.dart
│   │   ├── downloads_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       ├── anime_card.dart
│       ├── manga_card.dart
│       ├── shimmer_skeleton.dart
│       ├── buttons.dart
│       ├── custom_bottom_nav.dart
│       └── error_views.dart
└── main.dart
```

---

## 3. API Specifications

### 3.1 Jikan API (Anime Data)

**Base URL:** `https://api.jikan.moe/v4`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/anime` | GET | List anime with filters |
| `/anime/{id}` | GET | Anime details |
| `/anime/{id}/episodes` | GET | Episode list |
| `/top/anime` | GET | Top ranked anime |
| `/seasons/now` | GET | Current season anime |
| `/schedules` | GET | Weekly release schedule |
| `/search/anime` | GET | Search anime |

**Rate Limit:** 3 requests/second

### 3.2 MangaDex API (Manga Data)

**Base URL:** `https://api.mangadex.org`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/manga` | GET | List manga |
| `/manga/{id}` | GET | Manga details |
| `/manga/{id}/feed` | GET | Chapter list |
| `/chapter/{id}` | GET | Chapter details |
| `/at-home/server/{chapterId}` | GET | Chapter images |
| `/cover` | GET | Cover images |

**Rate Limit:** 5 requests/second per IP

### 3.3 Request Models

```dart
// Anime Query Parameters
class AnimeQueryParams {
  final int? page;
  final int? limit;
  final String? search;
  final String? type; // tv, movie, ova, etc.
  final String? status; // airing, complete, upcoming
  final String? rating; // g, pg, pg13, r17, r
  final String? orderBy; // title, type, rating, start_date
  final bool? sortDesc;
}

// Manga Query Parameters  
class MangaQueryParams {
  final int? limit;
  final int? offset;
  final String? title;
  final List<String>? includedTags;
  final List<String>? excludedTags;
  final String? status;
  final String? contentRating; // safe, suggestive, erotica
  final String? orderBy;
}
```

---

## 4. Data Models

### 4.1 Core Models

```dart
// Anime Model
class Anime {
  final String id;
  final String title;
  final String? coverImage;
  final String? synopsis;
  final double? rating;
  final String? type;
  final int? episodes;
  final String? status;
  final List<String> genres;
  final int? year;
}

// Manga Model
class Manga {
  final String id;
  final String title;
  final String? coverImage;
  final String? description;
  final double? rating;
  final String? status;
  final List<String> tags;
  final int? year;
  final String? contentRating;
}

// Chapter Model
class Chapter {
  final String id;
  final String mangaId;
  final String? title;
  final String? chapterNumber;
  final int? volumeNumber;
  final int? pages;
  final DateTime? publishedAt;
  final String? scanlationGroup;
}

// Episode Model
class Episode {
  final String id;
  final String animeId;
  final int episodeNumber;
  final String? title;
  final String? synopsis;
  final DateTime? aired;
}
```

### 4.2 User Models

```dart
// User Model
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;
  final DateTime createdAt;
  final List<String> favorites;
  final Map<String, dynamic> preferences;
}

// Reading Progress Model
class ReadingProgress {
  final String id;
  final String mangaId;
  final String chapterId;
  final String mangaTitle;
  final String chapterNumber;
  final String? coverImage;
  final int currentPage;
  final int totalPages;
  final DateTime lastReadAt;
}

// Bookmark Model
class Bookmark {
  final String id;
  final String mangaId;
  final String chapterId;
  final String mangaTitle;
  final String chapterNumber;
  final String? coverImage;
  final DateTime createdAt;
}
```

---

## 5. Local Storage (Hive)

### 5.1 Box Structure

| Box Name | Type | Purpose |
|----------|------|---------|
| `anime_cache` | `Anime` | Cached anime data |
| `manga_cache` | `Manga` | Cached manga data |
| `reading_progress` | `ReadingProgressHive` | Reading positions |
| `bookmarks` | `BookmarkHive` | User bookmarks |
| `downloads` | `DownloadTask` | Download queue |
| `user_prefs` | `dynamic` | User preferences |
| `search_history` | `String` | Recent searches |

### 5.2 Type IDs

| Model | TypeId |
|-------|--------|
| ReadingProgressHive | 2 |
| BookmarkHive | 3 |
| DownloadTask | 4 |
| UserSettings | 5 |

---

## 6. State Management (Riverpod)

### 6.1 Provider Categories

```dart
// Services
final jikanServiceProvider = Provider((ref) => JikanService());
final mangadexServiceProvider = Provider((ref) => MangaDexService());
final authServiceProvider = Provider((ref) => AuthService());

// Anime State
final trendingAnimeProvider = FutureProvider((ref) async {
  final service = ref.watch(jikanServiceProvider);
  return service.getTrendingAnime();
});

final topAnimeProvider = FutureProvider((ref) async {
  final service = ref.watch(jikanServiceProvider);
  return service.getTopAnime();
});

final seasonalAnimeProvider = FutureProvider((ref) async {
  final service = ref.watch(jikanServiceProvider);
  return service.getSeasonalAnime();
});

final searchAnimeProvider = FutureProvider.family<List<Anime>, String>((ref, query) async {
  final service = ref.watch(jikanServiceProvider);
  return service.searchAnime(query);
});

// Manga State
final popularMangaProvider = FutureProvider((ref) async {
  final service = ref.watch(mangadexServiceProvider);
  return service.getPopularManga();
});

final latestMangaProvider = FutureProvider((ref) async {
  final service = ref.watch(mangadexServiceProvider);
  return service.getLatestManga();
});

final mangaChaptersProvider = FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  final service = ref.watch(mangadexServiceProvider);
  return service.getChapters(mangaId);
});

// Auth State
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

final currentUserProvider = Provider((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.when(
    authenticated: (user) => user,
    guest: () => null,
    initial: () => null,
    loading: () => null,
    error: (_) => null,
  );
});
```

---

## 7. Security Requirements

### 7.1 Data Security

| Aspect | Implementation |
|--------|----------------|
| API Keys | Stored in `.env`, never committed |
| User Data | Encrypted in Firebase |
| Local Cache | Hive with encryption support |
| Network | HTTPS only |
| Deep Links | Verified domains only |

### 7.2 Environment Configuration

```bash
# .env file (not in version control)
FIREBASE_API_KEY=xxx
FIREBASE_APP_ID=xxx
MANGADEX_CLIENT_ID=xxx
```

---

## 8. Performance Requirements

### 8.1 Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Launch | < 3s | Cold start |
| Time to Interactive | < 2s | After splash |
| API Response | < 500ms | Cached data |
| Image Load | < 1s | Cached images |
| Video Start | < 5s | First frame |
| Frame Rate | 60fps | UI animations |
| Memory Usage | < 150MB | Peak usage |
| App Size | < 100MB | APK size |

### 8.2 Optimization Strategies

- **Image Caching:** LRU cache with 100 image limit
- **API Caching:** 1-hour cache for static data
- **Lazy Loading:** Paginated lists with 20 items/page
- **Code Splitting:** Deferred loading for heavy screens
- **Image Compression:** WebP format with fallbacks

---

## 9. Error Handling

### 9.1 Error Types

| Type | Handling | User Message |
|------|----------|--------------|
| Network Error | Retry with exponential backoff | "Check connection" |
| API Error | Cache fallback | "Using offline data" |
| Auth Error | Redirect to login | "Session expired" |
| Not Found | 404 screen | "Content not found" |
| Server Error | Retry later | "Server busy" |
| Unknown Error | Log & report | "Something went wrong" |

### 9.2 Error Widgets

```dart
// Error View
ErrorView(
  title: 'No Internet',
  message: 'Check your connection',
  icon: Icons.wifi_off,
  onRetry: () => ref.refresh(provider),
)

// Empty State
EmptyStateView(
  title: 'No Results',
  message: 'Try different search terms',
  icon: Icons.search_off,
)

// Loading State
LoadingView(message: 'Loading anime...')
```

---

## 10. Testing Strategy

### 10.1 Test Levels

| Level | Coverage | Tools |
|-------|----------|-------|
| Unit Tests | 80% business logic | flutter_test |
| Widget Tests | Critical screens | flutter_test |
| Integration | User flows | integration_test |
| E2E | Full scenarios | patrol |

### 10.2 Critical Test Cases

- Anime search with filters
- Manga chapter reading flow
- Download and offline playback
- Reading progress persistence
- Auth state transitions

---

## 11. Deployment

### 11.1 Build Configuration

```bash
# Android Release
flutter build apk --release
flutter build appbundle --release

# iOS Release
flutter build ios --release
```

### 11.2 CI/CD Pipeline

1. **Lint** - Static analysis
2. **Test** - Unit & widget tests
3. **Build** - Android & iOS
4. **Sign** - Release signing
5. **Deploy** - App stores

---

## 12. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  video_player: ^2.8.2
  chewie: ^1.7.4
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.1.6
  shimmer: ^3.0.0
  share_plus: ^7.2.1
  path_provider: ^2.1.1
  photo_view: ^0.15.0
  intl: ^0.19.0
  url_launcher: ^6.2.4
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.2.2
```

---

**Document Version:** 1.0  
**Last Updated:** March 2026  
**Status:** Approved
