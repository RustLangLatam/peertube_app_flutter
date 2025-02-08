import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'package:peertube_app_flutter/utils/export.dart';

import '../pages/video_page.dart';
import '../providers/api_provider.dart';

const int pageSize = 10;

class ListVideosWidget extends ConsumerStatefulWidget {
  final int? categoryId; // If null, fetch all videos
  final String node;
  final String? sortBy;
  final bool isLive;

  final PagingController<int, Video>? externalPagingController;

  const ListVideosWidget({
    super.key,
    this.categoryId,
    required this.node,
    this.externalPagingController,
    this.isLive = false,
    this.sortBy,
  });

  @override
  ConsumerState<ListVideosWidget> createState() => _ListVideosWidgetState();
}

class _ListVideosWidgetState extends ConsumerState<ListVideosWidget> {
  late final PagingController<int, Video> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController =
        widget.externalPagingController ?? PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(fetchVideos);
  }

  @override
  void didUpdateWidget(covariant ListVideosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.sortBy != widget.sortBy) ||
        (oldWidget.isLive != widget.isLive)) {
      _refreshVideos();
    }
  }

  Future<void> fetchVideos(int pageKey) async {
    try {
      final categoryOneOf = widget.categoryId != null
          ? GetAccountVideosCategoryOneOfParameter(
              (p) => p..oneOf = OneOf.fromValue1(value: widget.categoryId!))
          : null;

      final api = ref.read(videoApiProvider());

      final response = await api.getVideos(
          categoryOneOf: categoryOneOf,
          start: pageKey,
          count: pageSize,
          isLive: widget.isLive,
          nsfw: 'false',
          sort: widget.sortBy,
          skipCount: 'true');

      if (response.statusCode == 200) {
        final videosList = response.data?.data?.toList() ?? [];
        final isLastPage = videosList.length < pageSize;

        isLastPage
            ? _pagingController.appendLastPage(videosList)
            : _pagingController.appendPage(videosList, pageKey + pageSize);
      } else {
        _pagingController.error =
            'Failed to load videos: ${response.statusCode}';
      }
    } catch (error) {
      _pagingController.error = 'Error fetching videos: $error';
    }
  }

  /// **Refresh videos without clearing immediately**
  Future<void> _refreshVideos() async {
    try {
      final categoryOneOf = widget.categoryId != null
          ? GetAccountVideosCategoryOneOfParameter(
              (p) => p..oneOf = OneOf.fromValue1(value: widget.categoryId!))
          : null;

      final api = ref.read(videoApiProvider());

      final response = await api.getVideos(
          categoryOneOf: categoryOneOf,
          start: 0,
          count: pageSize,
          isLive: widget.isLive,
          nsfw: 'false',
          sort: widget.sortBy,
          skipCount: 'true');

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
    if (widget.externalPagingController == null) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video List with Refresh Indicator
        RefreshIndicator(
          color: Colors.orangeAccent,
          backgroundColor: Colors.transparent,
          displacement: 30,
          strokeWidth: 1.5,
          elevation: 2,
          onRefresh: _refreshVideos, // Refresh without clearing UI
          child: PagedListView<int, Video>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Video>(
              itemBuilder: (context, video, index) =>
                  _buildVideoListItem(video),
              firstPageProgressIndicatorBuilder: (_) =>
                  _buildShimmerEffect(), // Show skeleton while loading first page
              newPageProgressIndicatorBuilder: (_) =>
                  UIUtils.progressIndicatorPlaceholder(), // Pagination
            ),
          ),
        ),

        // Blur Effect at the Bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.grey.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds video list items
  Widget _buildVideoListItem(Video video) {
    final thumbnailURL =
        video.previewPath != null ? '${widget.node}${video.previewPath}' : '';

    return InkWell(
      highlightColor: const Color(0xFF1A1A1A).withOpacity(0.7),
      splashColor: const Color(0xFF1A1A1A).withOpacity(0.5),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VideoPlayerScreen(node: widget.node, video: video),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return Stack(
                children: [
                  FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1), // Start slightly below
                      end: Offset.zero, // End at the normal position
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut, // Smooth out the animation
                    )),
                    child: child,
                  ),
                ],
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 150),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Video Thumbnail
                UIUtils.buildHeroVideoThumbnail(
                  thumbnailURL: thumbnailURL,
                  useRoundedCorners: true,
                ),

                // Video Duration (Bottom Right)
                Positioned(
                  right: 0,
                  bottom: -1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(6)),
                    ),
                    child: Text(
                      VideoDateUtils.formatSecondsToTime(video.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Channel Avatar (Overlapping Bottom Left)
                Positioned(
                  bottom: -20,
                  left: 12,
                  child: AvatarUtils.buildAvatarFromVideoDetails(
                      video, widget.node),
                ),
              ],
            ),

            // Channel Name & Video Title
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 10, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    VideoUtils.extractDisplayName(video),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    video.name ?? "Unknown Video",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Video Metadata (Upload Time & Views)
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 10, top: 3),
              child: Text(
                "${VideoDateUtils.formatRelativeDate(video.publishedAt)} • ${VideoUtils.formatViews(video.views)}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Main Shimmer Effect Function**
  /// Wraps the entire list in a Shimmer effect
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[700]!,
      child: Column(
        children: List.generate(6, (index) => _buildShimmerRow()),
      ),
    );
  }

  /// **Single Shimmer Row (Skeleton of Video List Item)**
  Widget _buildShimmerRow() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Thumbnail Placeholder**
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  height: 180, // Same as video thumbnail
                  color: Colors.grey[900],
                ),
              ),

              // **Channel Avatar Placeholder (Overlapping Bottom Left)**
              Positioned(
                bottom: -19,
                left: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // **Row for Avatar and Video Info**
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 10, top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Channel Name Placeholder**
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey[900],
                ),
                const SizedBox(height: 8),

                // **Video Title Placeholder**
                Container(
                  width: double.infinity,
                  height: 10,
                  color: Colors.grey[900],
                ),
              ],
            ),
          ),

          // **Video Metadata Placeholder (Upload Time & Views)**
          Padding(
            padding:
                const EdgeInsets.only(left: 50, right: 10, top: 13, bottom: 1),
            child: Container(
              width: 150,
              height: 12,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
