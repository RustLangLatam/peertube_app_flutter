import 'package:flutter/material.dart';

import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../widgets/list_channels_widget.dart';
import '../widgets/peertube_logo_widget.dart';

class ChannelsScreen extends StatefulWidget {
  final PeerTubeApiSdk api;

  const ChannelsScreen({super.key, required this.api});

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
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
      body: Column(children: [
        Expanded(
          child: ListChannelsWidget(api: widget.api),
        )
      ]),
    );
  }

  /// Builds the app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: PeerTubeTextWidget(text: 'Channels'),
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
