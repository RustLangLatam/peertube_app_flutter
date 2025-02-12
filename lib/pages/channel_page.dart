import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../providers/api_provider.dart';
import '../utils/avatar_utils.dart';
import '../utils/buttons_utils.dart';
import '../utils/channels_utils.dart';
import '../utils/ui_utils.dart';
import '../utils/video_date_utils.dart';
import '../widgets/blurred_backdrop_image.dart';
import '../widgets/expandable_text_widget.dart';
import '../widgets/list_channel_videos_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class ChannelScreen extends ConsumerStatefulWidget {
  final String node;
  final VideoChannelSummary channel; // ✅ Optional
  final List<Video> initialVideos;

  const ChannelScreen({
    super.key,
    required this.node,
    required this.channel,
    this.initialVideos = const [], // ✅ Optional
  });

  @override
  ConsumerState<ChannelScreen> createState() => _VideoChannelScreenState();
}

class _VideoChannelScreenState extends ConsumerState<ChannelScreen> {
  static const double collapsedBarHeight = 60.0;
  static const double expandedBarHeight = 90.0;

  double titleOpacity = 0.0;

  late ScrollController _scrollController;
  bool isCollapsed = false;
  bool didAddFeedback = false;

  VideoChannel? videoChannel;

  int _videoCount = 0;
  bool isTrending = false;
  bool recentlyAdded = true;
  String sortBy = '-publishedAt';
  bool isLive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchVideoChannel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final fadeStart = expandedBarHeight * 0.4; // ✅ Start fading later
    final fadeEnd = expandedBarHeight - collapsedBarHeight;

    double newOpacity = 1 - ((offset - fadeStart) / (fadeEnd - fadeStart));
    newOpacity = newOpacity.clamp(0, 1); // ✅ Keep value between 0 and 1

    if (newOpacity != titleOpacity) {
      setState(() {
        titleOpacity = newOpacity; // ✅ Title fades in as you scroll up
        isCollapsed =
            newOpacity <= 0; // ✅ Fully collapsed when opacity reaches 0
      });
    }
  }

  String getChannelHandle(VideoChannelSummary channel) {
    return "${channel.name}@${channel.host}";
  }

  Future<void> fetchVideoChannel() async {
    try {
      final api = ref.read(videoChannelsApiProvider());

      final channelHandle = getChannelHandle(widget.channel);

      final response = await api.getVideoChannel(
        channelHandle: channelHandle,
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          videoChannel = response.data;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching channel: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        isCollapsed = _scrollController.hasClients &&
            _scrollController.offset > (expandedBarHeight - collapsedBarHeight);
        if (isCollapsed && !didAddFeedback) {
          HapticFeedback.mediumImpact();
          didAddFeedback = true;
        } else if (!isCollapsed) {
          didAddFeedback = false;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF13100E),
        body: Stack(
          children: [
            BlurredBackdropImage(channel: videoChannel, node: widget.node),
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildChannelInfo()),
                _buildFiltersSection(),
                _buildVideosSection(),
              ],
            ),
            // Blur Effect at the Bottom
            UIUtils.blurEffectAtTheBottom()
          ],
        ),
      ),
    );
  }

  /// 🔹 **SliverAppBar with Banner**
  SliverAppBar _buildAppBar() {
    final bannerUrl = videoChannel?.banners?.isNotEmpty == true
        ? widget.node + videoChannel!.banners!.first.path!
        : null;

    return SliverAppBar(
      expandedHeight: expandedBarHeight,
      collapsedHeight: collapsedBarHeight,
      centerTitle: false,
      pinned: true,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: titleOpacity,
        child: PeerTubeTextWidget(
            text: widget.channel.displayName ?? 'Unknown Channel',
            underlined: true),
      ),
      elevation: 0,
      backgroundColor: Color.lerp(
        Colors.transparent,
        const Color(0xFF1A1A1A),
        Curves.easeOut.transform(titleOpacity), // ✅ Smooth fade-in effect
      ),
      leading: const BackButton(
        color: Colors.white,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: bannerUrl != null
            ? CachedNetworkImage(
                imageUrl: bannerUrl,
                fit: BoxFit.contain, // ✅ Makes the image fit well
                fadeInDuration:
                    const Duration(milliseconds: 500), // ✅ Smooth fade-in
                fadeOutDuration:
                    Duration.zero, // ✅ Prevents abrupt placeholder removal
                placeholder: (context, url) => _defaultBanner(),
                errorWidget: (context, url, error) => _defaultBanner(),
              )
            : _defaultBanner(),
      ),
    );
  }

  /// 🔹 **Channel Info**
  Widget _buildChannelInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AvatarUtils.buildChannelAvatar(
                  channel: widget.channel,
                  host: widget.node,
                  height: 40,
                  width: 40),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PeerTubeTextWidget(text: ChannelsUtils.extractChannelDisplayName(widget.channel), fontSize: 17.5),
                    Text(
                      ChannelsUtils.extractChannelDisplayName(widget.channel, prioritizeChannel: true),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(
                              text:
                                  "${videoChannel?.followersCount ?? 0} followers  "),
                          const TextSpan(
                            text: "•",
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "  $_videoCount videos"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ButtonsUtils.subscribeButton(
                onPressed: () {
                  UIUtils.showTemporaryBottomDialog(
                      context, "Subscription feature not implemented yet.");
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (videoChannel?.description != null)
            buildExpandableText(text: videoChannel!.description!)
          else
            const SizedBox(
              height: 15 * 2.0, // ✅ Reserve space for 2 lines of text
              child: Text(
                " ", // Invisible space to keep height consistent
                style: TextStyle(fontSize: 15, color: Colors.transparent),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 2),
              Text(
                "Created ${VideoDateUtils.formatRelativeDate(videoChannel?.createdAt)}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.grey),
        ],
      ),
    );
  }

  /// 🔹 **Filters Section**
  Widget _buildFiltersSection() {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _SliverFixedHeaderDelegate(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xCC13100E), // 🔹 80% opacity at the top
                Color(0xFF13100E), // 🔹 Fully opaque at the bottom
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(), // ✅ Filters now update correctly
            ],
          ),
        ),
      ),
    );
  }

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            UIUtils.filterToggleButton(
              "Recently Added",
              Icons.new_releases_outlined,
              recentlyAdded,
              () {
                setState(() {
                  recentlyAdded = true;
                  isTrending = false;
                  sortBy = '-publishedAt';
                });
              },
            ),
            const SizedBox(width: 5),
            UIUtils.filterToggleButton(
              "Trending",
              Icons.trending_up,
              isTrending,
              () {
                setState(() {
                  recentlyAdded = false;
                  isTrending = true;
                  sortBy = '-trending';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Videos Section**
  Widget _buildVideosSection() {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListChannelVideosWidget(
                  node: widget.node,
                  channelName: getChannelHandle(widget.channel),
                  sortBy: sortBy,
                  isLive: isLive,
                  videoCountCallback: (videoCount) {
                    setState(() {
                      _videoCount = videoCount;
                    });
                  },
                  initialVideos: widget.initialVideos),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Default Banner**
  Widget _defaultBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF282828), Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.video_library, size: 50, color: Colors.white54),
    );
  }
}

class _SliverFixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxExtentHeight;
  final double minExtentHeight;

  _SliverFixedHeaderDelegate({required this.child, this.maxExtentHeight = 48.0, this.minExtentHeight = 48.0});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return StatefulBuilder(
      // ✅ Rebuild only this section when state changes
      builder: (context, setState) {
        return child;
      },
    );
  }

  @override
  double get maxExtent => maxExtentHeight;
  @override
  double get minExtent => minExtentHeight;
  @override
  bool shouldRebuild(covariant _SliverFixedHeaderDelegate oldDelegate) => true;
}
