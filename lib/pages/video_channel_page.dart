import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../utils/avatar_utils.dart';
import '../utils/buttons_utils.dart';
import '../utils/channels_utils.dart';
import '../utils/ui_utils.dart';
import '../widgets/list_channel_videos_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class VideoChannelScreen extends StatefulWidget {
  final String node;
  final VideoChannel channel;

  const VideoChannelScreen({
    super.key,
    required this.node,
    required this.channel,
  });

  @override
  _VideoChannelScreenState createState() => _VideoChannelScreenState();
}

class _VideoChannelScreenState extends State<VideoChannelScreen> {
  int _videoCount = 0;
  bool isTrending = false;
  bool recentlyAdded = true;
  String sortBy = '-publishedAt';
  bool isLive = false;

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
    final bannerUrl = widget.channel.banners?.isNotEmpty == true
        ? widget.node + widget.channel.banners!.first.path!
        : null;

    return SliverAppBar(
      expandedHeight: 180,
      leading: PeerTubeLogoWidget(),
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      actions: [
        Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
            child: IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: Colors.orange),
              onPressed: () => Navigator.of(context).pop(),
            ))
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

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
          height: 30,
          child: Row(
            children: [
              UIUtils.filterToggleButton(
                  "Recently Added", Icons.add, recentlyAdded, onTap: () {
                setState(() {
                  recentlyAdded = true;
                  isTrending = false;
                  sortBy = '-publishedAt';
                });
                // // TODO: Implement recently added videos
                // UIUtils.showTemporaryBottomDialog(context, "Feature coming soon!");
              }),
              const SizedBox(width: 5),
              UIUtils.filterToggleButton(
                  "Trending", Icons.trending_up, isTrending, onTap: () {
                setState(() {
                  recentlyAdded = false;
                  isTrending = true;
                  sortBy = '-trending';
                });
                // // TODO: Implement trending videos
                // UIUtils.showTemporaryBottomDialog(context, "Feature coming soon!");
              }),
            ],
          )),
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
              AvatarUtils.buildAvatarFromVideoChannel(
                  widget.channel, widget.node),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ChannelsUtils.extractVideoChannelDisplayName(
                          widget.channel),
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
                          TextSpan(
                            text:
                                "${widget.channel.followersCount ?? 0} followers  ",
                          ),
                          TextSpan(
                            text: "•",
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "  $_videoCount videos",
                          ),
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
          if (widget.channel.description != null &&
              widget.channel.description!.isNotEmpty)
            Text(widget.channel.description!,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Created on ${widget.channel.createdAt?.toLocal().toString().split(' ')[0] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.grey),
        ],
      ),
    );
  }

  String getChannelHandle(VideoChannel channel) {
    return "${channel.name}@${channel.host}";
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
              Text("Videos",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              _buildFilters()
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
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
