import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../providers/api_provider.dart';
import '../utils/avatar_utils.dart';
import '../utils/ui_utils.dart';
import '../utils/video_utils.dart';
import '../widgets/peertube_logo_widget.dart';

class OverviewData {
  Widget? title;
  final List<Video> videos;

  OverviewData(this.title, this.videos);
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
            itemBuilder: (context, overview, index) =>
                _buildSection(overview.title!, overview.videos),
            firstPageProgressIndicatorBuilder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
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
  Widget _buildSection(Widget titleWidget, List<Video> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: titleWidget, // ✅ Dynamic title widget
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoUtils.buildDiscoverVideoItem(
                  videos[index], widget.node);
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
                _buildTitleWidget(tag.tag ?? 'Unknown Tag', isTag: true),
                _extractVideos(tag.videos!.asList()),
              ),
            ),
      );
    }

    allSections.shuffle(Random()); // Shuffle once to maintain order
    return allSections;
  }
}
