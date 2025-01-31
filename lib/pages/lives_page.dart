
import 'package:flutter/material.dart';

import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../widgets/coming_soon_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class LivesScreen extends StatefulWidget {
  final PeerTubeApiSdk api;

  const LivesScreen({super.key, required this.api});

  @override
  _LivesScreenState createState() => _LivesScreenState();
}

class _LivesScreenState extends State<LivesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: ComingSoonWidget(),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: PeerTubeTextWidget(text: 'Live'),
      leading: PeerTubeLogoWidget(),
      actions: [
        IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {}),
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