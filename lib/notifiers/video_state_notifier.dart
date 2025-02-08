// Import necessary packages
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/api_provider.dart';

// Generate the Riverpod notifier code
part 'video_state_notifier.g.dart';

/// A Riverpod notifier for managing the [VideoDetails] state
@riverpod
class VideoDetailsState extends _$VideoDetailsState {
  /// Initialize the video state with a loading value
  @override
  AsyncValue<VideoDetails> build() => const AsyncValue.loading();

  /// Fetch a video by its ID
  ///
  /// Parameters:
  /// * [id] - The object ID, UUID, or short UUID of the VideoDetails to fetch
  ///
  /// Returns a Future that completes when the video is fetched
  Future<void> fetchVideo({required String id}) async {
    try {
      // Get the video API provider
      final api = ref.read(videoApiProvider());

      // Fetch the video using the API provider
      final response = await api.getVideo(
        id: ApiV1VideosOwnershipIdAcceptPostIdParameter(
              (p) => p..oneOf = OneOf.fromValue1(value: id),
        ),
      );

      // Check if the response was successful and the video data has changed
      if (response.statusCode == 200 && response.data != state.value) {
        // Update the video state with the fetched data
        state = AsyncData(response.data!);
      }
    } catch (e) {
      // Update the video state with an error if the fetch fails
      state = AsyncError(e, StackTrace.current);
    }
  }
}
