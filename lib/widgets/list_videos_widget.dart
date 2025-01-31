import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peertube_app_flutter/utils.dart';
import '../pages/video_page.dart';

const int pageSize = 10;

class ListVideosWidget extends StatefulWidget {
  final int? categoryId; // If null, fetch all videos
  final PeerTubeApiSdk api;
  final PagingController<int, Video>? externalPagingController;

  const ListVideosWidget({
    super.key,
    this.categoryId,
    required this.api,
    this.externalPagingController,
  });

  @override
  State<ListVideosWidget> createState() => _ListVideosWidgetState();
}

class _ListVideosWidgetState extends State<ListVideosWidget> {
  late final PagingController<int, Video> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController =
        widget.externalPagingController ?? PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(fetchVideos);
  }

  Future<void> fetchVideos(int pageKey) async {
    try {
      final categoryOneOf = widget.categoryId != null
          ? GetAccountVideosCategoryOneOfParameter(
              (p) => p..oneOf = OneOf.fromValue1(value: widget.categoryId!))
          : null;

      final response = await widget.api.getVideoApi().getVideos(
          categoryOneOf: categoryOneOf, start: pageKey, count: pageSize);

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
        // Video List
        RefreshIndicator(
          onRefresh: () => Future.sync(_pagingController.refresh),
          child: PagedListView<int, Video>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Video>(
              itemBuilder: (context, video, index) =>
                  _buildVideoListItem(video),
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
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.5),
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
    final thumbnailURL = video.previewPath != null
        ? '${widget.api.getHost}${video.previewPath}'
        : '';

    final channelData = video.channel;
    final channelName = channelData?.name ?? "Unknown Channel";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) =>
                HlsVideoPlayerPage(videoId: video.id!, api: widget.api),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: thumbnailURL,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
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
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(4), bottomRight: Radius.circular(6)),
                    ),
                    child: Text(
                      Utils.formatSecondsToTime(video.duration),
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
                      video, widget.api.getHost),
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
                    channelName,
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
                "${Utils.formatRelativeDate(video.publishedAt)} • ${Utils.formatViews(video.views)}",
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
}
