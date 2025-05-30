// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/extentions/video_ext.dart';
import 'package:peertube_app_flutter/widgets/list_videos_widget.dart';
import 'package:peertube_toolkit/peertube_toolkit.dart';

import '../widgets/peertube_logo_widget.dart';

class CategoryVideosScreen extends ConsumerStatefulWidget {
  final VideoConstantNumberCategory category;

  final String node;

  final List<Video> initialVideos;

  const CategoryVideosScreen(
      {required this.node,
      required this.category,
      this.initialVideos = const []});

  @override
  _CategoryVideosScreenState createState() => _CategoryVideosScreenState();
}

class _CategoryVideosScreenState extends ConsumerState<CategoryVideosScreen> {
  int _videoCount = 0;

  bool isTrending = false;
  bool recentlyAdded = true;
  String sortBy = '-publishedAt';
  bool isLive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16), // ✅ Added padding around body
        child: Column(
          children: [
            _buildFiltersSection(),
            Divider(color: Colors.grey[700]),
            Expanded(
              child: ListVideosWidget(
                  categoryId: widget.category.oneOfParameter,
                  // Fetch all videos
                  node: widget.node,
                  gridView: true,
                  sortBy: sortBy,
                  isLive: isLive,
                  skipCount: false,
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

  /// Builds the app bar with search & settings
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: PeerTubeTextWidget(
          text: "${widget.category.label}", underlined: true),
      leading: const PeerTubeLogoWidget(),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(), // ✅ Ensures filters are inside SliverToBoxAdapter
          const SizedBox(height: 8), // 🔹 Add spacing
          Text(
            'Total: ${VideoUtils.formatVideosCount(_videoCount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
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
              onTap: () {
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
              onTap: () {
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
