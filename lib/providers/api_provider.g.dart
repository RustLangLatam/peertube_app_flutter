// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$peerTubeApiHash() => r'cab39344c9f6c541d41df8a56de67335e6c2ca05';

/// ✅ **Provider to get the PeerTube API (uses global baseUrlProvider)**
///
/// Copied from [peerTubeApi].
@ProviderFor(peerTubeApi)
final peerTubeApiProvider = Provider<PeerTubeApiSdk>.internal(
  peerTubeApi,
  name: r'peerTubeApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$peerTubeApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PeerTubeApiRef = ProviderRef<PeerTubeApiSdk>;
String _$videoApiHash() => r'8deeada370556f9a58b1ea9ea38eb12bc8c8ea14';

/// ✅ **Provider to get the Video API**
///
/// Copied from [videoApi].
@ProviderFor(videoApi)
final videoApiProvider = Provider<VideoApi>.internal(
  videoApi,
  name: r'videoApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videoApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoApiRef = ProviderRef<VideoApi>;
String _$videoChannelsApiHash() => r'6558a34f956bbed0a347121e224d73835151f083';

/// ✅ **Provider to get the Video Channels API**
///
/// Copied from [videoChannelsApi].
@ProviderFor(videoChannelsApi)
final videoChannelsApiProvider = Provider<VideoChannelsApi>.internal(
  videoChannelsApi,
  name: r'videoChannelsApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoChannelsApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoChannelsApiRef = ProviderRef<VideoChannelsApi>;
String _$overviewVideosApiHash() => r'f2498b91a8a308877cfb4d05b65653691925c388';

/// ✅ **Provider to get the Overview Videos API**
///
/// Copied from [overviewVideosApi].
@ProviderFor(overviewVideosApi)
final overviewVideosApiProvider = Provider<OverviewVideosApi>.internal(
  overviewVideosApi,
  name: r'overviewVideosApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overviewVideosApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverviewVideosApiRef = ProviderRef<OverviewVideosApi>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
