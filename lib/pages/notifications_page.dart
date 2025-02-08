import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../widgets/coming_soon_widget.dart';

class NotificationsScreen extends StatefulWidget {
  final PeerTubeApiSdk api;

  const NotificationsScreen({super.key, required this.api});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
      title: Text(
        'Lives',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/logo.png"),
      ),
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
