import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/api_provider.dart';

part 'video_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class VideoDetailsState extends _$VideoDetailsState {
  /// Store the last used search parameters
  String _lastQueryHash = '';
  List<Video> _currentVideos = [];

  @override
  AsyncValue<List<Video>> build() => const AsyncData([]);

  /// Fetch videos with optimized state management
  Future<void> fetchVideos({
    GetAccountVideosCategoryOneOfParameter? categoryOneOf,
    bool? isLive,
    GetAccountVideosTagsOneOfParameter? tagsOneOf,
    GetAccountVideosTagsAllOfParameter? tagsAllOf,
    GetAccountVideosLicenceOneOfParameter? licenceOneOf,
    GetAccountVideosLanguageOneOfParameter? languageOneOf,
    GetAccountVideosTagsAllOfParameter? autoTagOneOf,
    String? nsfw,
    bool? isLocal,
    int? include,
    VideoPrivacySet? privacyOneOf,
    bool? hasHLSFiles,
    bool? hasWebVideoFiles,
    String? skipCount = 'false',
    int? start,
    int? count = 10,
    String? sort,
    bool? excludeAlreadyWatched,
    String? search,
  }) async {
    try {
      final api = ref.read(videoApiProvider);

      // 🟢 Generate a hash to detect changes in search parameters (excluding `start`)
      final queryHash = _generateQueryHash(
        categoryOneOf,
        isLive,
        tagsOneOf,
        tagsAllOf,
        licenceOneOf,
        languageOneOf,
        autoTagOneOf,
        nsfw,
        isLocal,
        include,
        privacyOneOf,
        hasHLSFiles,
        hasWebVideoFiles,
        skipCount,
        count,
        sort,
        excludeAlreadyWatched,
        search,
      );

      // 🟢 Fetch videos
      final response = await api.getVideos(
        categoryOneOf: categoryOneOf,
        isLive: isLive,
        tagsOneOf: tagsOneOf,
        tagsAllOf: tagsAllOf,
        licenceOneOf: licenceOneOf,
        languageOneOf: languageOneOf,
        autoTagOneOf: autoTagOneOf,
        nsfw: nsfw,
        isLocal: isLocal,
        include: include,
        privacyOneOf: privacyOneOf,
        hasHLSFiles: hasHLSFiles,
        hasWebVideoFiles: hasWebVideoFiles,
        skipCount: skipCount,
        start: start,
        count: count,
        sort: sort,
        excludeAlreadyWatched: excludeAlreadyWatched,
        search: search,
      );

      if (response.statusCode == 200 && response.data != null) {
        final newVideos = response.data!.data?.asList() ?? [];

        if (queryHash == _lastQueryHash && start != null) {
          // ✅ If only `start` changed, append new items
          _currentVideos.addAll(newVideos);
        } else {
          // ✅ If any other parameter changed, reset list
          _currentVideos = newVideos;
          _lastQueryHash = queryHash;
        }

        state = AsyncData([..._currentVideos]);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// **Generate a unique hash for search parameters (excluding `start`)**
  String _generateQueryHash(
    GetAccountVideosCategoryOneOfParameter? categoryOneOf,
    bool? isLive,
    GetAccountVideosTagsOneOfParameter? tagsOneOf,
    GetAccountVideosTagsAllOfParameter? tagsAllOf,
    GetAccountVideosLicenceOneOfParameter? licenceOneOf,
    GetAccountVideosLanguageOneOfParameter? languageOneOf,
    GetAccountVideosTagsAllOfParameter? autoTagOneOf,
    String? nsfw,
    bool? isLocal,
    int? include,
    VideoPrivacySet? privacyOneOf,
    bool? hasHLSFiles,
    bool? hasWebVideoFiles,
    String? skipCount,
    int? count,
    String? sort,
    bool? excludeAlreadyWatched,
    String? search,
  ) {
    return [
      categoryOneOf?.toString(),
      isLive?.toString(),
      tagsOneOf?.toString(),
      tagsAllOf?.toString(),
      licenceOneOf?.toString(),
      languageOneOf?.toString(),
      autoTagOneOf?.toString(),
      nsfw,
      isLocal?.toString(),
      include?.toString(),
      privacyOneOf?.toString(),
      hasHLSFiles?.toString(),
      hasWebVideoFiles?.toString(),
      skipCount,
      count?.toString(),
      sort,
      excludeAlreadyWatched?.toString(),
      search
    ].join('|'); // Combine all parameters into a unique hash
  }
}
