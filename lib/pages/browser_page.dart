import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/export.dart';
import '../widgets/list_videos_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  final String node;

  const BrowserScreen({super.key, required this.node});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  bool isTrending = false;
  bool recentlyAdded = true;
  String sortBy = '-publishedAt';
  bool isLive = false;
  bool isLoading = false; // 🔹 Track if videos are loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(), // 🟢 Ensures filters appear below the AppBar
          Expanded(
            child: _buildVideoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return Stack(
      children: [
        Opacity(
          opacity: isLoading ? 0.0 : 1.0, // hide videos while loading.
          child: ListVideosWidget(
            node: widget.node,
            isLive: isLive,
            sortBy: sortBy,
            onLoading: (loading) {
              setState(() => isLoading = loading);
            },
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Center(child: VideoUtils.buildShimmerEffect()),
          ),
      ],
    );
  }

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UIUtils.filterToggleButton(
            "Recently Added",
            Icons.add,
            recentlyAdded,
            onTap: (isLoading ||
                    recentlyAdded) // Prevent re-selecting active button
                ? null
                : () {
                    setState(() {
                      isLoading = true;
                      recentlyAdded = true;
                      isTrending = false;
                      isLive = false;
                      sortBy = '-publishedAt';
                    });
                  },
          ),
          const SizedBox(width: 5),
          UIUtils.filterToggleButton(
            "Trending",
            Icons.trending_up,
            isTrending,
            onTap:
                (isLoading || isTrending) // Prevent re-selecting active button
                    ? null
                    : () {
                        setState(() {
                          isLoading = true;
                          isTrending = true;
                          recentlyAdded = false;
                          isLive = false;
                          sortBy = '-trending';
                        });
                      },
          ),
          const SizedBox(width: 5),
          UIUtils.filterToggleButton(
            "Live",
            Icons.podcasts_rounded,
            isLive,
            activeIconColor: Colors.redAccent,
            onTap: (isLoading || isLive) // Prevent re-selecting active button
                ? null
                : () {
                    setState(() {
                      isLoading = true;
                      isTrending = false;
                      recentlyAdded = false;
                      isLive = true;
                      sortBy = '-publishedAt';
                    });
                  },
          ),
        ],
      ),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const PeerTubeTextWidget(),
      leading:
          PeerTubeLogoWidget(isLoading: isLoading), // 🔹 Pass isLoading state
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            UIUtils.showTemporaryBottomDialog(context, "Search coming soon!");
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            UIUtils.showTemporaryBottomDialog(context, "Settings coming soon!");
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () {
            UIUtils.showTemporaryBottomDialog(context, "Account coming soon!");
          },
        ),
      ],
    );
  }
}
