import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/pages/video_channel_page.dart';
import 'package:peertube_app_flutter/pages/video_page.dart';
import 'package:shimmer/shimmer.dart';

import '../pages/category_page.dart';
import '../pages/channel_page.dart';
import '../pages/tag_page.dart';
import '../providers/api_provider.dart';
import '../transitions/custom_page_route.dart';
import '../utils/avatar_utils.dart';
import '../utils/ui_utils.dart';
import '../utils/video_utils.dart';
import '../widgets/peertube_logo_widget.dart';
import 'list_videos_widget.dart';

/// Enum for section types
enum SectionType { all, tags, categories, channels }

/// Data structure for paginated video overview
class OverviewData {
  String? label;
  SectionType type;
  Widget title;
  final List<Video> videos;

  OverviewData(
      {this.label,
      required this.type,
      required this.title,
      required this.videos});
}

class OverviewDataWidget extends ConsumerStatefulWidget {
  final String node;
  final bool all;
  final bool channels;
  final bool tags;
  final bool category;

  const OverviewDataWidget(
      {super.key,
      required this.node,
      this.all = true,
      this.channels = false,
      this.tags = false,
      this.category = false});

  @override
  ConsumerState<OverviewDataWidget> createState() => _DiscoverScreenState();
}

String _generateSignature(OverviewVideosResponse data) {
  return data.hashCode.toString(); // Uses hashCode as a lightweight signature
}

class _DiscoverScreenState extends ConsumerState<OverviewDataWidget> {
  String? _firstPageSignature; // Stores the first page signature
  late final PagingController<int, OverviewData> _pagingController;
  final ScrollController _scrollController = ScrollController(); // ✅ Add this

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(fetchOverview);
  }

  @override
  void didUpdateWidget(covariant OverviewDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.all != widget.all) ||
        (oldWidget.channels != widget.channels) ||
        (oldWidget.tags != widget.tags) ||
        oldWidget.category != widget.category) {
      if (_scrollController.hasClients) {
        _scrollController
            .animateTo(
          0.0,
          duration: const Duration(milliseconds: 300), // ✅ Smooth transition
          curve: Curves.easeOut, // ✅ Smooth deceleration effect
        )
            .then((_) async {
          // ✅ Scroll to the top
          // ✅ Only refresh AFTER the scroll animation completes
          await _refreshOverview();
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300), // ✅ Smooth transition
            curve: Curves.easeOut, // ✅ Smooth deceleration effect
          );
          // _scrollController.jumpTo(0.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ Dispose to avoid memory leaks
    _pagingController.dispose();
    super.dispose();
  }

  /// Fetches paginated video overview
  Future<void> fetchOverview(int pageKey) async {
    if (kDebugMode) {
      print('🔹 FetchingOverview page $pageKey');
    }

    try {
      final api = ref.read(overviewVideosApiProvider());
      final response = await api.getOverviewVideos(page: pageKey);

      if (response.statusCode == 200 && response.data != null) {
        final isLastPage = response.data!.categories!.isEmpty &&
            response.data!.channels!.isEmpty &&
            response.data!.tags!.isEmpty;

        if (pageKey == 1) {
          _firstPageSignature = _generateSignature(response.data!);
        }

        final data = _generateSections(response.data!);

        if (isLastPage) {
          _pagingController.appendLastPage(data);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(data, nextPageKey);
        }
      } else {
        _pagingController.error =
            'Failed to load videos: ${response.statusCode}';
      }
    } catch (error) {
      _pagingController.error = 'Error fetching videos: $error';
    }
  }

  /// Refreshes the overview
  Future<void> _refreshOverview() async {
    if (kDebugMode) {
      print('🔹 Refreshing overview');
    }

    try {
      final api = ref.read(overviewVideosApiProvider());
      final response = await api.getOverviewVideos(page: 1);

      if (response.statusCode == 200 && response.data != null) {
        final newSignature = _generateSignature(response.data!);

        // 🔹 Compare only with the first page signature
        if (_firstPageSignature != null &&
            _firstPageSignature == newSignature) {
          if (kDebugMode) {
            print('🔹 No changes detected in page 1, skipping UI update.');
          }
          return; // Skip UI update if data remains the same
        }

        final newOverview = _generateSections(response.data!);

        _pagingController.value = PagingState<int, OverviewData>(
          nextPageKey: 2, // ✅ Only continue fetching if there are videos
          itemList: newOverview,
          error: null,
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error refreshing videos: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      RefreshIndicator(
        color: Colors.orangeAccent,
        backgroundColor: Colors.transparent,
        displacement: 30,
        strokeWidth: 1.5,
        elevation: 2,
        onRefresh: _refreshOverview,
        child: PagedListView<int, OverviewData>(
          pagingController: _pagingController,
          scrollController: _scrollController, // ✅ Attach the ScrollController
          padding: const EdgeInsets.symmetric(vertical: 8),
          builderDelegate: PagedChildBuilderDelegate<OverviewData>(
            itemBuilder: (context, overview, index) => _buildSection(overview),
            firstPageProgressIndicatorBuilder: (_) => _buildShimmerEffect(),
            newPageProgressIndicatorBuilder: (_) =>
                UIUtils.progressIndicatorPlaceholder(),
          ),
        ),
      ),

      // Blur Effect at the Bottom
      UIUtils.blurEffectAtTheBottom()
    ]);
  }

  /// 🔹 Extracts videos safely
  List<Video> _extractVideos(List<Video>? videos) {
    return (videos ?? []).take(10).toList();
  }

  /// Builds a section with a dynamic title widget and a horizontal video list
  Widget _buildSection(OverviewData overview) {
    // ✅ Apply filtering based on selected filters
    bool shouldBuildSection = widget.all ||
        (widget.channels && overview.type == SectionType.channels) ||
        (widget.tags && overview.type == SectionType.tags) ||
        (widget.category && overview.type == SectionType.categories);

    if (!shouldBuildSection) {
      return const SizedBox.shrink(); // Skip building if filtered out
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: overview.title, // ✅ Dynamic title widget
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: overview.videos.length,
            itemBuilder: (context, index) {
              return
                  // 🎞️ Video Thumbnail
                  VideoUtils.buildMinimalVideoItem(
                      overview.videos[index], widget.node, onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                        const Duration(milliseconds: 300), // Smooth transition
                    reverseTransitionDuration:
                        const Duration(milliseconds: 150),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        VideoPlayerScreen(
                      node: widget.node,
                      video: overview.videos[index],
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  /// Builds a title widget with an underline matching the total width of its content.
  /// Builds a title widget with an underline exactly matching its content width.
  Widget _buildTitleWidget(String title, {Widget? avatar, bool isTag = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min, // Keeps width dynamic
                  children: [
                    if (avatar != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: avatar,
                      ), // 🔹 Avatar (if present)
                    if (avatar != null)
                      const SizedBox(width: 8), // 🔹 Spacing after avatar
                    Flexible(
                      child: Text(
                        isTag ? '#$title' : title, // 🔹 Tags get a '#' prefix
                        maxLines: 1, // 🔹 Prevents multi-line overflow
                        overflow:
                            TextOverflow.ellipsis, // 🔹 Adds "..." if too long
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: -2, // 🔹 Adjusts underline below text
                  child: Container(
                    width: constraints
                        .maxWidth, // 🔹 Matches title width dynamically
                    height: 4,
                    color: Colors.orange, // 🔹 Underline color
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Generates sections based on categories, channels, and tags
  List<OverviewData> _generateSections(OverviewVideosResponse overview) {
    final allSections = <OverviewData>[];

    if (overview.categories != null && overview.categories!.isNotEmpty) {
      allSections.addAll(
        overview.categories!.asList().map(
              (category) => OverviewData(
                label: category.category!.id.toString(),
                type: SectionType.categories,
                title: GestureDetector(
                  onTap: () => _navigateToCategory(
                      category.category!, category.videos!.asList()),
                  child: _buildTitleWidget(
                    category.category?.label ?? 'Unknown Category',
                  ),
                ),
                videos: _extractVideos(category.videos!.asList()),
              ),
            ),
      );
    }

    if (overview.channels != null && overview.channels!.isNotEmpty) {
      allSections.addAll(
        overview.channels!.asList().map(
              (channel) => OverviewData(
                label: channel.channel!.id.toString(),
                type: SectionType.channels,
                title: GestureDetector(
                  onTap: () => _navigateToChannel(
                    channel.channel!,
                    channel.videos!.asList(),
                  ), // ✅ Clickable Avatar
                  child: _buildTitleWidget(
                    channel.channel?.displayName ?? 'Unknown Channel',
                    avatar: AvatarUtils.buildChannelAvatar(
                      channel: channel.channel!,
                      host: widget.node,
                    ),
                  ),
                ),
                videos: _extractVideos(channel.videos!.asList()),
              ),
            ),
      );
    }

    if (overview.tags != null && overview.tags!.isNotEmpty) {
      allSections.addAll(
        overview.tags!.asList().map(
              (tag) => OverviewData(
                label: tag.tag,
                type: SectionType.tags,
                title: GestureDetector(
                  onTap: () => _navigateToTags(
                    tag.tag!,
                    tag.videos!.asList(),
                  ), // ✅ Clickable Avatar
                  child:
                      _buildTitleWidget(tag.tag ?? 'Unknown Tag', isTag: true),
                ),
                videos: _extractVideos(tag.videos!.asList()),
              ),
            ),
      );
    }

    allSections.shuffle(Random()); // Shuffle once to maintain order
    return allSections;
  }

  /// Navigates to the channel page
  void _navigateToChannel(VideoChannelSummary channel, List<Video> initialVideos) {
    Navigator.push(
      context,
      CustomPageRoute.build(
          ChannelScreen(
              channel: channel,
              node: widget.node,
              initialVideos: initialVideos),
          TransitionType.fade),
    );
  }

  /// Navigates to the category page
  void _navigateToCategory(
      VideoConstantNumberCategory category, List<Video> initialVideos) {
    Navigator.push(
      context,
      CustomPageRoute.build(
          CategoryVideosScreen(
              category: category, // Fetch all videos
              node: widget.node,
              initialVideos: initialVideos),
          TransitionType.fade),
    );
  }

  /// Navigates to the tag page
  void _navigateToTags(String tag, List<Video> initialVideos) {
    Navigator.push(
      context,
      CustomPageRoute.build(
          TagVideosScreen(
              tag: tag, // Fetch all videos
              node: widget.node,
              initialVideos: initialVideos),
          TransitionType.fade),
    );
  }

  /// **Main Shimmer Effect Function**
  /// Wraps the entire list in a Shimmer effect
  Widget _buildShimmerEffect() {
    return Column(
      children: List.generate(6, (index) => _shimmerEffect()),
    );
  }

  /// **Main Shimmer Effect Function**
  Widget _shimmerEffect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              width: 120,
              height: 20,
              color: Colors.grey[800], // Simulates the title
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // Simulates 5 loading items
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Simulated video thumbnail
                    Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(
                        width: 160,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // 🔹 Simulated video title
                    Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(
                        width: 140,
                        height: 15,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 3),
                    // 🔹 Simulated metadata
                    Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(
                        width: 100,
                        height: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
