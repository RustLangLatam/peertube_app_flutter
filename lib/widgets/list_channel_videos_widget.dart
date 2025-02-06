import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/ui_utils.dart';
import '../utils/video_date_utils.dart';
import '../pages/video_page.dart';
import '../utils/video_utils.dart';
import 'list_videos_widget.dart';

const int pageSize = 10;

class ListChannelVideosWidget extends StatefulWidget {
  final PeerTubeApiSdk api;
  final String channelName;
  final String? sortBy;
  final bool isLive;

  final void Function(int count)? videoCountCallback;

  const ListChannelVideosWidget({
    super.key,
    required this.api,
    required this.channelName,
    this.videoCountCallback,
    this.isLive = false,
    this.sortBy,
  });

  @override
  _ListChannelVideosWidgetState createState() =>
      _ListChannelVideosWidgetState();
}

class _ListChannelVideosWidgetState extends State<ListChannelVideosWidget> {
  late final PagingController<int, Video> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchVideos);
  }

  @override
  void didUpdateWidget(covariant ListChannelVideosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.sortBy != widget.sortBy) ||
        (oldWidget.isLive != widget.isLive)) {
      _refreshVideos();
    }
  }

  Future<void> _fetchVideos(int pageKey) async {
    try {
      final response =
          await widget.api.getVideoChannelsApi().getVideoChannelVideos(
                channelHandle: widget.channelName,
                start: pageKey,
                count: pageSize,
                sort: widget.sortBy,
                skipCount: 'false',
                isLive: widget.isLive,
                nsfw: 'false',
              );

      if (response.statusCode == 200) {
        final videos = response.data?.data?.toList() ?? [];
        final isLastPage = videos.length < pageSize;

        if (widget.videoCountCallback != null) {
          widget.videoCountCallback!(response.data?.total ?? 0);
        }

        isLastPage
            ? _pagingController.appendLastPage(videos)
            : _pagingController.appendPage(videos, pageKey + pageSize);
      } else {
        _pagingController.error = 'Failed to load videos';
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching videos: $error");
      }
      _pagingController.error = 'Error fetching videos';
    }
  }

  /// **Refresh videos without clearing immediately**
  Future<void> _refreshVideos() async {
    try {
      final response = await widget.api
          .getVideoChannelsApi()
          .getVideoChannelVideos(
              channelHandle: widget.channelName,
              start: 0,
              count: pageSize,
              isLive: widget.isLive,
              nsfw: 'false',
              sort: widget.sortBy,
              skipCount: 'false');

      if (response.statusCode == 200) {
        final newVideos = response.data?.data?.toList() ?? [];

        // Only replace if new videos are different from the current first pageSize list
        if (!_areListsEqual(
            (_pagingController.itemList ?? []).take(pageSize).toList(),
            newVideos)) {
          _replaceVideoList(newVideos);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error refreshing videos: $error');
      }
    }
  }

  /// **Replace the current list without clearing the UI immediately**
  void _replaceVideoList(List<Video> newVideos) {
    _pagingController.value = PagingState<int, Video>(
      nextPageKey: newVideos.length < pageSize ? null : pageSize,
      itemList: newVideos,
      error: null,
    );
  }

  /// **Compare two lists to check if they are the same**
  bool _areListsEqual(List<Video> oldList, List<Video> newList) {
    if (oldList.length != newList.length) return false;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, Video>(
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Show 2 videos per row
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 11, // More compact
      ),
      builderDelegate: PagedChildBuilderDelegate<Video>(
        itemBuilder: (context, video, index) => _buildVideoCard(video),
        firstPageProgressIndicatorBuilder: (_) => _buildShimmerGrid(),
        newPageProgressIndicatorBuilder: (_) =>
            UIUtils.progressIndicatorPlaceholder(),
      ),
    );
  }

  /// Builds a compact video card with essential details
  Widget _buildVideoCard(Video video) {
    final thumbnailURL = video.previewPath != null
        ? '${widget.api.getHost}${video.previewPath}'
        : '';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VideoPlayerScreen(video: video, api: widget.api),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.hardEdge, // Prevents overflow
        child: Stack(
          children: [
            // 🔹 Thumbnail with duration overlay
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // 🎞️ Video Thumbnail
                    AspectRatio(
                      aspectRatio: 16 / 9, // Ensures consistent aspect ratio
                      child: CachedNetworkImage(
                        imageUrl: thumbnailURL,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmerContainer(),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54),
                        ),
                      ),
                    ),

                    // ▶ Play Icon (Centered)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black
                                .withOpacity(0.15), // More translucent
                            border: Border.all(
                              color:
                                  Colors.white.withOpacity(0.1), // Soft outline
                              width: 1.2,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          child: Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white
                                .withOpacity(0.25), // More subtle icon
                            size: 42,
                            shadows: [
                              Shadow(
                                blurRadius: 6, // Softer shadow
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 🕒 Video Duration (Bottom Right)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(6)),
                        ),
                        child: Text(
                          VideoDateUtils.formatSecondsToMinSec(video.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 🏷 Video Title
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 5, right: 5),
                  child: VideoUtils.buildVideoTitle(video.name, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// **Shimmer Loading Effect for Grid**
  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6, // Show 6 placeholders while loading
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 10,
      ),
      itemBuilder: (_, __) => _buildShimmerContainer(),
    );
  }

  /// **Shimmer Placeholder for Video Thumbnail**
  Widget _buildShimmerContainer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
