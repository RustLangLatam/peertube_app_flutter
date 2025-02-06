import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/avatar_utils.dart';
import '../utils/buttons_utils.dart';
import '../utils/channels_utils.dart';
import '../utils/ui_utils.dart';
import '../pages/video_channel_page.dart';
import 'expandable_text_widget.dart';

const int pageSize = 10;

class ListChannelsWidget extends StatefulWidget {
  final PeerTubeApiSdk api;

  const ListChannelsWidget({super.key, required this.api});

  @override
  _ListChannelsWidgetState createState() => _ListChannelsWidgetState();
}

class _ListChannelsWidgetState extends State<ListChannelsWidget> {
  late final PagingController<int, VideoChannel> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchChannels);
  }

  /// Fetches the list of PeerTube channels
  Future<void> _fetchChannels(int pageKey) async {
    try {
      final apiChannels = widget.api.getVideoChannelsApi();
      final response = await apiChannels.getVideoChannels(
        start: pageKey,
        count: pageSize,
        sort: "-createdAt",
      );
      if (response.statusCode == 200) {
        final videosList = response.data?.data?.toList() ?? [];
        final isLastPage = videosList.length < pageSize;

        isLastPage
            ? _pagingController.appendLastPage(videosList)
            : _pagingController.appendPage(videosList, pageKey + pageSize);
      } else {
        throw Exception("Failed to load channels: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching channels: $e");
      }
    }
  }

  /// **Refresh Channels without clearing immediately**
  Future<void> _refreshChannels() async {
    try {
      final apiChannels = widget.api.getVideoChannelsApi();
      final response = await apiChannels.getVideoChannels(
        start: 0,
        count: pageSize,
        sort: "-createdAt",
      );

      if (response.statusCode == 200) {
        final newChannels = response.data?.data?.toList() ?? [];

        // Only replace if new videos are different from the current first pageSize list
        if (!_areListsEqual(
            (_pagingController.itemList ?? []).take(pageSize).toList(),
            newChannels)) {
          _replaceChannelList(newChannels);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error refreshing videos: $error');
      }
    }
  }

  void _replaceChannelList(List<VideoChannel> newChannels) {
    _pagingController.value = PagingState<int, VideoChannel>(
      nextPageKey: newChannels.length < pageSize ? null : pageSize,
      itemList: newChannels,
      error: null,
    );
  }

  /// **Compare two lists to check if they are the same**
  bool _areListsEqual(List<VideoChannel> oldList, List<VideoChannel> newList) {
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
    return Stack(children: [
      // Video List with Refresh Indicator
      RefreshIndicator(
        color: Colors.orangeAccent,
        backgroundColor: Colors.transparent,
        displacement: 30,
        strokeWidth: 1.5,
        elevation: 2,
        onRefresh: _refreshChannels, // Refresh without clearing UI
        child: PagedListView<int, VideoChannel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<VideoChannel>(
            itemBuilder: (context, channel, index) =>
                _buildChannelCard(channel),
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
    ]);
  }

  /// Builds a channel card with a **PeerTube** design.
  Widget _buildChannelCard(VideoChannel channel) {
    final bannerUrl = channel.banners?.isNotEmpty == true
        ? widget.api.getHost + channel.banners!.first.path!
        : null;

    return InkWell(
      highlightColor: const Color(0xFF1A1A1A).withOpacity(0.7),
      splashColor: const Color(0xFF1A1A1A).withOpacity(0.5),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VideoChannelScreen(channel: channel, api: widget.api),
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
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Banner Image with Avatar Overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 📌 Channel Banner (or Default)
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
                  child: CachedNetworkImage(
                    imageUrl: bannerUrl ?? "",
                    width: double.infinity,
                    height: 80, // ⬅ Reduced height for compactness
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _defaultBanner(),
                    errorWidget: (context, url, error) => _defaultBanner(),
                  ),
                ),

                // 🔹 Channel Avatar (Overlapping)
                Positioned(
                  left: 12,
                  bottom: -16, // Smaller overlap
                   child: AvatarUtils.buildAvatarFromVideoChannel(channel, widget.api.getHost),
                ),
              ],
            ),

            // 🔹 Channel Info
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 12, top: 20, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📌 Channel Name
                            Text(
                              ChannelsUtils.extractDisplayName(channel),
                              style: const TextStyle(
                                fontSize: 14, // ⬅ Slightly smaller
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            // 📌 Channel Description (Max 2 Lines)
                            SizedBox(
                              height: 38, // Fixed height to avoid resizing
                              child: buildExpandableText(
                                text: channel.description ?? "No description",
                              ),
                            ),

                            const SizedBox(height: 2),

                            // 📌 Subscribers Count
                            Text(
                              "${channel.followersCount} subscribers",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6)),
                            ),
                            const SizedBox(height: 2),
                          ])),

                  // 📌 Subscribe Button (Left-aligned)
                  ButtonsUtils.subscribeButton(
                    onPressed: () {
                      UIUtils.showTemporaryBottomDialog(
                          context, "Subscription feature not implemented yet.");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Column(
      children: List.generate(6, (index) => _buildShimmerRow()),
    );
  }

  Widget _buildShimmerRow() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            // 🔹 Shimmer Banner Placeholder
            _buildShimmerContainer(
              width: double.infinity,
              height: 80,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),

            // 🔹 Shimmer Avatar (Overlapping)
            Positioned(
              left: 12,
              bottom: -16,
              child: _buildShimmerContainer(
                width: 36,
                height: 36,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ]),

          // 🔹 Shimmer Channel Info
          Padding(
            padding:
                const EdgeInsets.only(left: 31, right: 12, top: 23, bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📌 Shimmer Channel Name
                      _buildShimmerContainer(height: 12, width: 120),
                      const SizedBox(height: 8),

                      // 📌 Shimmer Channel Description
                      _buildShimmerContainer(height: 10, width: 230),
                      const SizedBox(height: 31),

                      // 📌 Shimmer Subscribers Count
                      _buildShimmerContainer(height: 10, width: 100),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),

                // 📌 Shimmer Subscribe Button
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: _buildShimmerContainer(
                      width: 107,
                      height: 36,
                      borderRadius: BorderRadius.circular(6)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Helper Function for Shimmer Containers
  Widget _buildShimmerContainer({
    required double height,
    required double width,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// Default banner when the channel doesn't have one
  Widget _defaultBanner() {
    return Container(
      height: 80, // Matches banner height
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A1E1E), // Dark reddish background
            const Color(0xFF3C2A2A), // Slightly lighter red-brown
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.subscriptions_sharp,
          color: Colors.white.withOpacity(0.3), // Subtle faded icon
          size: 32, // Medium icon size
        ),
      ),
    );
  }
}
