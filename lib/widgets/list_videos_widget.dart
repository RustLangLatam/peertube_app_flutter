import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peertube_toolkit/peertube_toolkit.dart';

import '../pages/video_page.dart';
import '../providers/api_provider.dart';

const int defaultPageSize = 10;

class ListVideosWidget extends ConsumerStatefulWidget {
  final GetAccountVideosCategoryOneOfParameter? categoryId; // If null, fetch all videos
  final GetAccountVideosTagsOneOfParameter? tagId;
  final String node;
  final String? sortBy;
  final bool isLive;
  final bool gridView;
  final bool skipCount;
  final void Function(int count)? videoCountCallback;
  final void Function(bool loading)? onLoading;
  final List<Video> initialVideos;

  const ListVideosWidget({
    super.key,
    this.categoryId,
    this.tagId,
    required this.node,
    this.isLive = false,
    this.sortBy,
    this.gridView = false,
    this.skipCount = true,
    this.videoCountCallback,
    this.onLoading,
    this.initialVideos = const [],
  });

  @override
  ConsumerState<ListVideosWidget> createState() => _ListVideosWidgetState();
}

class _ListVideosWidgetState extends ConsumerState<ListVideosWidget> {
  late final PagingController<int, Video> _pagingController;
  late int pageSize;

  @override
  void initState() {
    super.initState();
    pageSize = defaultPageSize;

    _pagingController = PagingController(firstPageKey: 0);

    if (widget.initialVideos.isNotEmpty) {
      if (widget.initialVideos.length > defaultPageSize) {
        pageSize = widget.initialVideos.length;
      }

      // ✅ Load initial videos first without fetching
      _pagingController.value = PagingState<int, Video>(
        nextPageKey: widget.initialVideos.length < pageSize ? null : pageSize,
        itemList: widget.initialVideos,
        error: null,
      );
    }

    _pagingController.addPageRequestListener(fetchVideos);

    Future.delayed(Duration.zero, () {
      setState(() {
        if (widget.videoCountCallback != null &&
            widget.initialVideos.isNotEmpty &&
            widget.initialVideos.length <= defaultPageSize) {
          widget.videoCountCallback!(widget.initialVideos.length);
        }
      });
    });
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
    if (kDebugMode) print('🔹 FetchingVideos page $pageKey');

    if (widget.initialVideos.isNotEmpty && pageKey == 0) {
      // ✅ Skip fetching if initialVideos exist
      return;
    }

    final api = ref.read(videoApiProvider);

    Future.microtask(() async {
      try {
        final response = await api.getVideos(
            categoryOneOf: widget.categoryId,
            tagsOneOf: widget.tagId,
            start: pageKey,
            count: pageSize,
            isLive: widget.isLive,
            nsfw: 'false',
            sort: widget.sortBy,
            skipCount: widget.skipCount.toString());

        if (response.statusCode == 200) {
          final videosList = response.data?.data?.toList() ?? [];
          final isLastPage = videosList.length < pageSize;

          if (widget.videoCountCallback != null) {
            widget.videoCountCallback!(response.data?.total ?? 0);
          }

          if (widget.onLoading != null) {
            widget.onLoading!(false);
          }

          isLastPage
              ? _pagingController.appendLastPage(videosList)
              : _pagingController.appendPage(videosList, pageKey + pageSize);
        } else {
          _pagingController.error =
          'Failed to load videos: ${response.statusCode}';
        }
      } catch (error) {
        if (kDebugMode) print('🔹 FetchingVideos error $error');

        _pagingController.error = 'Error fetching videos: $error';
      }
    });
  }

  /// **Refresh videos without clearing immediately**
  Future<void> _refreshVideos() async {
    try {
      final api = ref.read(videoApiProvider);

      final response = await api.getVideos(
          categoryOneOf: widget.categoryId,
          tagsOneOf: widget.tagId,
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

        if (widget.onLoading != null) {
          widget.onLoading!(false);
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
    return Stack(
      children: [
        // Video List with Refresh Indicator
        RefreshIndicator(
            color: Colors.orangeAccent,
            backgroundColor: Colors.transparent,
            displacement: 30,
            strokeWidth: 1.5,
            elevation: 2,
            onRefresh: _refreshVideos,
            // Refresh without clearing UI
            child: !widget.gridView
                ? PagedListView<int, Video>(
              pagingController: _pagingController,
              scrollDirection: Axis.vertical,
              builderDelegate: PagedChildBuilderDelegate<Video>(
                itemBuilder: (context, video, index) =>
                    _buildVideoListViewCard(video),
                firstPageProgressIndicatorBuilder: (_) =>
                    VideoUtils.buildShimmerEffect(),
                // Show skeleton while loading first page
                newPageProgressIndicatorBuilder: (_) =>
                    UIUtils.progressIndicatorPlaceholder(), // Pagination
              ),
            )
                : PagedGridView<int, Video>(
              pagingController: _pagingController,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Show 2 videos per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 16 / 14, // More compact
              ),
              builderDelegate: PagedChildBuilderDelegate<Video>(
                itemBuilder: (context, video, index) =>
                    _buildVideoGridViewCard(video),
                firstPageProgressIndicatorBuilder: (_) =>
                    VideoUtils.buildMinimalVideoBlurEffect(),
                // Show skeleton while loading first page
                newPageProgressIndicatorBuilder: (_) =>
                    UIUtils.progressIndicatorPlaceholder(), // Pagination
              ),
            )),

        // Blur Effect at the Bottom
        UIUtils.blurEffectAtTheBottom()
      ],
    );
  }

  /// Builds a compact video card with essential details
  Widget _buildVideoGridViewCard(Video video) {
    return
      // 🎞️ Video Thumbnail
      VideoUtils.buildMinimalVideoItem(video, widget.node, onTap: () {
        Navigator.push(
          context,
          CustomPageRoute.fade(VideoPlayerScreen(
            node: widget.node,
            video: video,
          )),
        );
      });
  }

  /// Builds video list items
  Widget _buildVideoListViewCard(Video video) {
    final thumbnailURL = VideoUtils.getVideoThumbnailUrl(video, widget.node);
    final isLive = (video.isLive != null && video.isLive!);

    return InkWell(
      highlightColor: const Color(0xFF1A1A1A).withOpacity(0.7),
      splashColor: const Color(0xFF1A1A1A).withOpacity(0.5),
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute.fade(
            VideoPlayerScreen(
              node: widget.node,
              video: video,
            ),
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
                  thumbnailURL: thumbnailURL ?? '',
                  useRoundedCorners: true,
                ),

                // Show either video duration or LIVE badge
                Positioned(
                  right: 0,
                  bottom: -1,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLive
                          ? Colors.redAccent
                          : Colors
                          .black45, // 🔴 "LIVE" uses red, duration uses black
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      isLive
                          ? "LIVE" // ✅ Show "LIVE" badge if live
                          : VideoDateUtils.formatSecondsToTime(
                          video.duration), // ✅ Show duration if not live
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
                    VideoUtils.extractNameOrDisplayName(video,
                        node: widget.node),
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
              child: Row(
                children: [
                  Text(
                    VideoDateUtils.formatRelativeDate(video.publishedAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.circle, size: 4, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    VideoUtils.formatViews(video.views),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
