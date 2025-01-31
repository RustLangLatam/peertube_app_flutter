import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/widgets/list_videos_widget.dart';

import '../utils.dart';
import '../widgets/peertube_logo_widget.dart';

class BrowserScreen extends StatefulWidget {
  final PeerTubeApiSdk api;

  const BrowserScreen({super.key, required this.api});

  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(), // 🟢 Ensures filters appear below the AppBar
          Expanded(
            child: ListVideosWidget(api: widget.api),
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
          Utils.filterToggleButton("Recently Added", Icons.add, true),
          const SizedBox(width: 5),
          Utils.filterToggleButton("Trending", Icons.trending_up, false),
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
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}