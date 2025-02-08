// providers/domain_user_api_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_provider.g.dart';

const String baseUrl = 'https://peertube.cpy.re';

/// Provider to get the peerTube api
@Riverpod(keepAlive: true)
PeerTubeApiSdk peerTubeApi(Ref ref, {String? apiBaseUrl}) {
  return PeerTubeApiSdk(basePathOverride: apiBaseUrl ?? baseUrl);
}

/// Provider to get the console domain api
@Riverpod(keepAlive: true)
VideoApi videoApi(Ref ref, {String? apiBaseUrl}) {
  final api = ref.read(peerTubeApiProvider(apiBaseUrl: apiBaseUrl ?? baseUrl));
  return api.getVideoApi();
}

/// Provider to get the domain user api
@Riverpod(keepAlive: true)
VideoChannelsApi videoChannelsApi(Ref ref, {String? apiBaseUrl}) {
  final api = ref.read(peerTubeApiProvider(apiBaseUrl: apiBaseUrl ?? baseUrl));
  return api.getVideoChannelsApi();
}

// TODO: Add more providers for other APIs
