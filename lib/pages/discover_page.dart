import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/export.dart';
import '../widgets/list_overview_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final String node;

  const DiscoverScreen({super.key, required this.node});

  @override
  ConsumerState<DiscoverScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<DiscoverScreen> {
  bool all = true;
  bool channels = false;
  bool tags = false;
  bool category = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(), // 🟢 Ensures filters appear below the AppBar
          Expanded(
            child: OverviewDataWidget(
                node: widget.node,
                all: all,
                channels: channels,
                category: category,
                tags: tags),
          ),
        ],
      ),
    );
  }

  /// Builds filter buttons
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 🔹 Enables horizontal scrolling
        child: Row(
          children: [
            UIUtils.filterToggleButton("All", Icons.grid_view, all, () {
              setState(() {
                all = true;
                channels = false;
                category = false;
                tags = false;
              });
            }),
            const SizedBox(width: 5),
            UIUtils.filterToggleButton(
                "Channels", Icons.subscriptions, channels, () {
              setState(() {
                all = false;
                channels = true;
                category = false;
                tags = false;
              });
            }),
            const SizedBox(width: 5),
            UIUtils.filterToggleButton("Categories", Icons.category, category,
                () {
              setState(() {
                all = false;
                channels = false;
                category = true;
                tags = false;
              });
            }),
            const SizedBox(width: 5),
            UIUtils.filterToggleButton("Tags", Icons.label_outline, tags, () {
              setState(() {
                all = false;
                channels = false;
                category = false;
                tags = true;
              });
            }),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const PeerTubeTextWidget(text: 'Discover'),
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
