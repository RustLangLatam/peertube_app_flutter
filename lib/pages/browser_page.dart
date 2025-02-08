import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peertube_app_flutter/widgets/list_videos_widget.dart';

import '../utils/export.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(), // 🟢 Ensures filters appear below the AppBar
          Expanded(
            child: ListVideosWidget(
                node: widget.node, isLive: isLive, sortBy: sortBy),
          ),
        ],
      ),
    );
  }

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          UIUtils.filterToggleButton("Recently Added", Icons.add, recentlyAdded,
              () {
            setState(() {
              recentlyAdded = true;
              isTrending = false;
              sortBy = '-publishedAt';
            });
            // // TODO: Implement recently added videos
            // UIUtils.showTemporaryBottomDialog(context, "Feature coming soon!");
          }),
          const SizedBox(width: 5),
          UIUtils.filterToggleButton("Trending", Icons.trending_up, isTrending,
              () {
            setState(() {
              recentlyAdded = false;
              isTrending = true;
              sortBy = '-trending';
            });
            // // TODO: Implement trending videos
            // UIUtils.showTemporaryBottomDialog(context, "Feature coming soon!");
          }),
        ],
      ),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const PeerTubeTextWidget(),
      leading: const PeerTubeLogoWidget(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // TODO: Implement search
            UIUtils.showTemporaryBottomDialog(context, "Search coming soon!");
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Implement settings
            UIUtils.showTemporaryBottomDialog(context, "Settings coming soon!");
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Implement account
            UIUtils.showTemporaryBottomDialog(context, "Account coming soon!");
          },
        ),
      ],
    );
  }
}
