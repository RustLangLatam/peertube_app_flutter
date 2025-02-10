import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/pages/video_channel_page.dart';
import 'package:peertube_app_flutter/pages/video_page.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/api_provider.dart';
import '../utils/avatar_utils.dart';
import '../utils/ui_utils.dart';
import '../utils/video_utils.dart';
import '../widgets/peertube_logo_widget.dart';

/// Enum for section types
enum SectionType { tags, categories, channels }

/// Data structure for paginated video overview
class OverviewData {
  String? label;
  SectionType type;
  Widget title;
  final List<Video> videos;

  OverviewData(this.label, this.type, this.title, this.videos);
}

class DiscoverScreen extends ConsumerStatefulWidget {
  final String node;

  const DiscoverScreen({super.key, required this.node});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String? _firstPageSignature; // Stores the first page signature
  late final PagingController<int, OverviewData> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(fetchOverview);
  }

  /// Fetches paginated video overview
  Future<void> fetchOverview(int pageKey) async {
    if (kDebugMode) {
      print('🔹 Fetching page $pageKey');
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
          nextPageKey: 2,
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

  String _generateSignature(OverviewVideosResponse data) {
    return data.hashCode.toString(); // Uses hashCode as a lightweight signature
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: Colors.orangeAccent,
        backgroundColor: Colors.transparent,
        displacement: 30,
        strokeWidth: 1.5,
        elevation: 2,
        onRefresh: _refreshOverview,
        child: PagedListView<int, OverviewData>(
          pagingController: _pagingController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          builderDelegate: PagedChildBuilderDelegate<OverviewData>(
            itemBuilder: (context, overview, index) => _buildSection(overview),
            firstPageProgressIndicatorBuilder: (_) => _buildShimmerEffect(),
            newPageProgressIndicatorBuilder: (_) =>
                UIUtils.progressIndicatorPlaceholder(),
          ),
        ),
      ),
    );
  }

  /// 🔹 Extracts videos safely
  List<Video> _extractVideos(List<Video>? videos) {
    return (videos ?? []).take(10).toList();
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: PeerTubeTextWidget(text: 'Discover'),
      leading: PeerTubeLogoWidget(),
      actions: [
        IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {}),
        IconButton(
            icon:
                const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {}),
      ],
    );
  }

  /// Builds a section with a dynamic title widget and a horizontal video list
  Widget _buildSection(OverviewData overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: overview.title, // ✅ Dynamic title widget
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: overview.videos.length,
            itemBuilder: (context, index) {
              return VideoUtils.buildDiscoverVideoItem(
                  overview.videos[index], widget.node, onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        VideoPlayerScreen(node: widget.node, video: overview.videos[index]),
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
              });
            },
          ),
        ),
      ],
    );
  }

  /// Builds a title widget based on type (Tag, Channel, Category)
  Widget _buildTitleWidget(String title, {Widget? avatar, bool isTag = false}) {
    if (isTag) {
      // 🔹 Tag: #TagName
      return Text(
        '#$title',
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (avatar != null) {
      // 🔹 Channel: Avatar + Title
      return Row(
        children: [
          avatar,
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      // 🔹 Category: Plain text title
      return Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );
    }
  }

  /// Generates sections based on categories, channels, and tags
  List<OverviewData> _generateSections(OverviewVideosResponse overview) {
    final allSections = <OverviewData>[];

    if (overview.categories != null && overview.categories!.isNotEmpty) {
      allSections.addAll(
        overview.categories!.asList().map(
              (category) => OverviewData(
                category.category!.id.toString(),
                SectionType.categories,
                _buildTitleWidget(
                    category.category?.label ?? 'Unknown Category'),
                _extractVideos(category.videos!.asList()),
              ),
            ),
      );
    }

    if (overview.channels != null && overview.channels!.isNotEmpty) {
      allSections.addAll(
        overview.channels!.asList().map(
              (channel) => OverviewData(
                channel.channel!.id.toString(),
                SectionType.channels,
                _buildTitleWidget(
                  channel.channel?.displayName ?? 'Unknown Channel',
                  avatar: AvatarUtils.buildChannelAvatar(
                    channel: channel.channel!,
                    host: widget.node,
                  ),
                ),
                _extractVideos(channel.videos!.asList()),
              ),
            ),
      );
    }

    if (overview.tags != null && overview.tags!.isNotEmpty) {
      allSections.addAll(
        overview.tags!.asList().map(
              (tag) => OverviewData(
                tag.tag,
                SectionType.tags,
                _buildTitleWidget(tag.tag ?? 'Unknown Tag', isTag: true),
                _extractVideos(tag.videos!.asList()),
              ),
            ),
      );
    }

    allSections.shuffle(Random()); // Shuffle once to maintain order
    return allSections;
  }

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
