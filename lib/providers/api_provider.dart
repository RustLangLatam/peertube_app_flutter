import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_provider.g.dart';

/// ✅ **Global State for API Base URL**
final baseUrlProvider = StateProvider<String>((ref) => 'https://peertube.tv');

/// ✅ **Provider to get the PeerTube API (uses global baseUrlProvider)**
@Riverpod(keepAlive: true)
PeerTubeApiSdk peerTubeApi(Ref ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return PeerTubeApiSdk(basePathOverride: baseUrl, debugMode: false);
}

/// ✅ **Provider to get the Video API**
@Riverpod(keepAlive: true)
VideoApi videoApi(Ref ref) {
  final api = ref.watch(peerTubeApiProvider);
  return api.getVideoApi();
}

/// ✅ **Provider to get the Video Channels API**
@Riverpod(keepAlive: true)
VideoChannelsApi videoChannelsApi(Ref ref) {
  final api = ref.watch(peerTubeApiProvider);
  return api.getVideoChannelsApi();
}

/// ✅ **Provider to get the Overview Videos API**
@Riverpod(keepAlive: true)
OverviewVideosApi overviewVideosApi(Ref ref) {
  final api = ref.watch(peerTubeApiProvider);
  return api.getOverviewVideosApi();
}

/// ✅ **Function to Initialize All API Providers with a Custom Base URL**
void initializeApiProviders(ProviderContainer container, {required String baseUrl}) {
  container.read(baseUrlProvider.notifier).state = baseUrl; // ✅ Updates the global base URL
  container.read(peerTubeApiProvider);
  container.read(videoApiProvider);
  container.read(videoChannelsApiProvider);
  container.read(overviewVideosApiProvider);
}

// TODO: Add more providers for other APIs
