import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peertube_toolkit/peertube_toolkit.dart';

import '../pages/video_page.dart';
import '../providers/api_provider.dart';

const int defaultPageSize = 10;

class ListChannelVideosWidget extends ConsumerStatefulWidget {
  final List<Video> initialVideos;

  final String node;
  final String channelName;
  final String? sortBy;
  final bool isLive;

  final void Function(int count)? videoCountCallback;

  const ListChannelVideosWidget({
    super.key,
    required this.node,
    required this.channelName,
    this.videoCountCallback,
    this.isLive = false,
    this.sortBy,
    this.initialVideos = const [],
  });

  @override
  ConsumerState<ListChannelVideosWidget> createState() =>
      _ListChannelVideosWidgetState();
}

class _ListChannelVideosWidgetState
    extends ConsumerState<ListChannelVideosWidget> {
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
    _pagingController.addPageRequestListener(_fetchVideos);
    Future.delayed(Duration.zero, () {
      setState(() {
        if (widget.videoCountCallback != null) {
          widget.videoCountCallback!(widget.initialVideos.length);
        }
      });
    });
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
    if (kDebugMode) print('🔹 FetchingChannelVideos page $pageKey');

    if (widget.initialVideos.isNotEmpty && pageKey == 0) {
      // ✅ Skip fetching if initialVideos exist
      return;
    }

    final api = ref.read(videoChannelsApiProvider);

    Future.microtask(() async {
      try {
      final response = await api.getVideoChannelVideos(
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
    });
  }

  /// **Refresh videos without clearing immediately**
  Future<void> _refreshVideos() async {
    try {
      final api = ref.read(videoChannelsApiProvider);

      final response = await api.getVideoChannelVideos(
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 16 / 14, // More compact
      ),
      builderDelegate: PagedChildBuilderDelegate<Video>(
        itemBuilder: (context, video, index) => _buildVideoCard(video),
        firstPageProgressIndicatorBuilder: (_) =>
            VideoUtils.buildMinimalVideoBlurEffect(),
        newPageProgressIndicatorBuilder: (_) =>
            UIUtils.progressIndicatorPlaceholder(),
      ),
    );
  }

  /// Builds a compact video card with essential details
  Widget _buildVideoCard(Video video) {
    // 🎞️ Video Thumbnail
    return VideoUtils.buildMinimalVideoItem(video, widget.node, onTap: () {
      Navigator.push(
        context,
        CustomPageRoute.fade(
            VideoPlayerScreen(video: video, node: widget.node)),
      );
    });
  }
}
