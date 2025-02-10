import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:uuid/uuid.dart';

import '../providers/api_provider.dart';
import '../utils/avatar_utils.dart';
import '../utils/buttons_utils.dart';
import '../utils/channels_utils.dart';
import '../utils/ui_utils.dart';
import '../widgets/list_channel_videos_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class ChannelScreen extends ConsumerStatefulWidget {
  final String node;
  final Channel channel; // ✅ Optional

  const ChannelScreen({
    super.key,
    required this.node,
    required this.channel, // ✅ Optional
  });

  @override
  ConsumerState<ChannelScreen> createState() => _VideoChannelScreenState();
}

class _VideoChannelScreenState extends ConsumerState<ChannelScreen> {
  VideoChannel? videoChannel;

  int _videoCount = 0;
  bool isTrending = false;
  bool recentlyAdded = true;
  String sortBy = '-publishedAt';
  bool isLive = false;

  @override
  void initState() {
    super.initState();
      fetchVideoChannel();
  }

  String getChannelHandle(Channel channel) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildChannelInfo()),
          _buildVideosSection(),
        ],
      ),
    );
  }

  /// 🔹 **SliverAppBar with Banner**
  Widget _buildSliverAppBar() {
    final bannerUrl = videoChannel?.banners?.isNotEmpty == true
        ? widget.node + videoChannel!.banners!.first.path!
        : null;

    return SliverAppBar(
      expandedHeight: 180,
      leading: const PeerTubeLogoWidget(),
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: bannerUrl != null
            ? CachedNetworkImage(
          imageUrl: bannerUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _defaultBanner(),
          errorWidget: (context, url, error) => _defaultBanner(),
        )
            : _defaultBanner(),
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

  /// 🔹 **Channel Info**
  Widget _buildChannelInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarUtils.buildChannelAvatar(channel:widget.channel, host:widget.node),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ChannelsUtils.extractChannelDisplayName(widget.channel) ?? "Unknown Channel",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(text: "${videoChannel?.followersCount ?? 0} followers  "),
                          const TextSpan(
                            text: "•",
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "  $_videoCount videos"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ButtonsUtils.subscribeButton(
                onPressed: () {
                  UIUtils.showTemporaryBottomDialog(
                      context, "Subscription feature not implemented yet.");
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (videoChannel?.description != null && videoChannel!.description!.isNotEmpty)
            Text(videoChannel!.description!,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Created on ${videoChannel?.createdAt?.toLocal().toString().split(' ')[0] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.grey),
        ],
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
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Text("Videos",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              _buildFilters(),
            ]),
            const SizedBox(height: 10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
}

