// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$peerTubeApiHash() => r'13304eb00850a319800fe84b04bcf2e45477e40a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider to get the peerTube api
///
/// Copied from [peerTubeApi].
@ProviderFor(peerTubeApi)
const peerTubeApiProvider = PeerTubeApiFamily();

/// Provider to get the peerTube api
///
/// Copied from [peerTubeApi].
class PeerTubeApiFamily extends Family<PeerTubeApiSdk> {
  /// Provider to get the peerTube api
  ///
  /// Copied from [peerTubeApi].
  const PeerTubeApiFamily();

  /// Provider to get the peerTube api
  ///
  /// Copied from [peerTubeApi].
  PeerTubeApiProvider call({
    String? apiBaseUrl,
  }) {
    return PeerTubeApiProvider(
      apiBaseUrl: apiBaseUrl,
    );
  }

  @override
  PeerTubeApiProvider getProviderOverride(
    covariant PeerTubeApiProvider provider,
  ) {
    return call(
      apiBaseUrl: provider.apiBaseUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'peerTubeApiProvider';
}

/// Provider to get the peerTube api
///
/// Copied from [peerTubeApi].
class PeerTubeApiProvider extends Provider<PeerTubeApiSdk> {
  /// Provider to get the peerTube api
  ///
  /// Copied from [peerTubeApi].
  PeerTubeApiProvider({
    String? apiBaseUrl,
  }) : this._internal(
          (ref) => peerTubeApi(
            ref as PeerTubeApiRef,
            apiBaseUrl: apiBaseUrl,
          ),
          from: peerTubeApiProvider,
          name: r'peerTubeApiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$peerTubeApiHash,
          dependencies: PeerTubeApiFamily._dependencies,
          allTransitiveDependencies:
              PeerTubeApiFamily._allTransitiveDependencies,
          apiBaseUrl: apiBaseUrl,
        );

  PeerTubeApiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.apiBaseUrl,
  }) : super.internal();

  final String? apiBaseUrl;

  @override
  Override overrideWith(
    PeerTubeApiSdk Function(PeerTubeApiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeerTubeApiProvider._internal(
        (ref) => create(ref as PeerTubeApiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        apiBaseUrl: apiBaseUrl,
      ),
    );
  }

  @override
  ProviderElement<PeerTubeApiSdk> createElement() {
    return _PeerTubeApiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeerTubeApiProvider && other.apiBaseUrl == apiBaseUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, apiBaseUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeerTubeApiRef on ProviderRef<PeerTubeApiSdk> {
  /// The parameter `apiBaseUrl` of this provider.
  String? get apiBaseUrl;
}

class _PeerTubeApiProviderElement extends ProviderElement<PeerTubeApiSdk>
    with PeerTubeApiRef {
  _PeerTubeApiProviderElement(super.provider);

  @override
  String? get apiBaseUrl => (origin as PeerTubeApiProvider).apiBaseUrl;
}

String _$videoApiHash() => r'ee9b44ceeca26c3aa6845298ffadaec7289c1e5c';

/// Provider to get the console domain api
///
/// Copied from [videoApi].
@ProviderFor(videoApi)
const videoApiProvider = VideoApiFamily();

/// Provider to get the console domain api
///
/// Copied from [videoApi].
class VideoApiFamily extends Family<VideoApi> {
  /// Provider to get the console domain api
  ///
  /// Copied from [videoApi].
  const VideoApiFamily();

  /// Provider to get the console domain api
  ///
  /// Copied from [videoApi].
  VideoApiProvider call({
    String? apiBaseUrl,
  }) {
    return VideoApiProvider(
      apiBaseUrl: apiBaseUrl,
    );
  }

  @override
  VideoApiProvider getProviderOverride(
    covariant VideoApiProvider provider,
  ) {
    return call(
      apiBaseUrl: provider.apiBaseUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoApiProvider';
}

/// Provider to get the console domain api
///
/// Copied from [videoApi].
class VideoApiProvider extends Provider<VideoApi> {
  /// Provider to get the console domain api
  ///
  /// Copied from [videoApi].
  VideoApiProvider({
    String? apiBaseUrl,
  }) : this._internal(
          (ref) => videoApi(
            ref as VideoApiRef,
            apiBaseUrl: apiBaseUrl,
          ),
          from: videoApiProvider,
          name: r'videoApiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoApiHash,
          dependencies: VideoApiFamily._dependencies,
          allTransitiveDependencies: VideoApiFamily._allTransitiveDependencies,
          apiBaseUrl: apiBaseUrl,
        );

  VideoApiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.apiBaseUrl,
  }) : super.internal();

  final String? apiBaseUrl;

  @override
  Override overrideWith(
    VideoApi Function(VideoApiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoApiProvider._internal(
        (ref) => create(ref as VideoApiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        apiBaseUrl: apiBaseUrl,
      ),
    );
  }

  @override
  ProviderElement<VideoApi> createElement() {
    return _VideoApiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoApiProvider && other.apiBaseUrl == apiBaseUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, apiBaseUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoApiRef on ProviderRef<VideoApi> {
  /// The parameter `apiBaseUrl` of this provider.
  String? get apiBaseUrl;
}

class _VideoApiProviderElement extends ProviderElement<VideoApi>
    with VideoApiRef {
  _VideoApiProviderElement(super.provider);

  @override
  String? get apiBaseUrl => (origin as VideoApiProvider).apiBaseUrl;
}

String _$videoChannelsApiHash() => r'ec44a4f1784fa3b447ab143433ac84774986d6a1';

/// Provider to get the domain user api
///
/// Copied from [videoChannelsApi].
@ProviderFor(videoChannelsApi)
const videoChannelsApiProvider = VideoChannelsApiFamily();

/// Provider to get the domain user api
///
/// Copied from [videoChannelsApi].
class VideoChannelsApiFamily extends Family<VideoChannelsApi> {
  /// Provider to get the domain user api
  ///
  /// Copied from [videoChannelsApi].
  const VideoChannelsApiFamily();

  /// Provider to get the domain user api
  ///
  /// Copied from [videoChannelsApi].
  VideoChannelsApiProvider call({
    String? apiBaseUrl,
  }) {
    return VideoChannelsApiProvider(
      apiBaseUrl: apiBaseUrl,
    );
  }

  @override
  VideoChannelsApiProvider getProviderOverride(
    covariant VideoChannelsApiProvider provider,
  ) {
    return call(
      apiBaseUrl: provider.apiBaseUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoChannelsApiProvider';
}

/// Provider to get the domain user api
///
/// Copied from [videoChannelsApi].
class VideoChannelsApiProvider extends Provider<VideoChannelsApi> {
  /// Provider to get the domain user api
  ///
  /// Copied from [videoChannelsApi].
  VideoChannelsApiProvider({
    String? apiBaseUrl,
  }) : this._internal(
          (ref) => videoChannelsApi(
            ref as VideoChannelsApiRef,
            apiBaseUrl: apiBaseUrl,
          ),
          from: videoChannelsApiProvider,
          name: r'videoChannelsApiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoChannelsApiHash,
          dependencies: VideoChannelsApiFamily._dependencies,
          allTransitiveDependencies:
              VideoChannelsApiFamily._allTransitiveDependencies,
          apiBaseUrl: apiBaseUrl,
        );

  VideoChannelsApiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.apiBaseUrl,
  }) : super.internal();

  final String? apiBaseUrl;

  @override
  Override overrideWith(
    VideoChannelsApi Function(VideoChannelsApiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoChannelsApiProvider._internal(
        (ref) => create(ref as VideoChannelsApiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        apiBaseUrl: apiBaseUrl,
      ),
    );
  }

  @override
  ProviderElement<VideoChannelsApi> createElement() {
    return _VideoChannelsApiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoChannelsApiProvider && other.apiBaseUrl == apiBaseUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, apiBaseUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoChannelsApiRef on ProviderRef<VideoChannelsApi> {
  /// The parameter `apiBaseUrl` of this provider.
  String? get apiBaseUrl;
}

class _VideoChannelsApiProviderElement extends ProviderElement<VideoChannelsApi>
    with VideoChannelsApiRef {
  _VideoChannelsApiProviderElement(super.provider);

  @override
  String? get apiBaseUrl => (origin as VideoChannelsApiProvider).apiBaseUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
