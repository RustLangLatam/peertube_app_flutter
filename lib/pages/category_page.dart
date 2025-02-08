// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/widgets/list_videos_widget.dart';

import '../widgets/peertube_logo_widget.dart';

class CategoryVideosScreen extends ConsumerStatefulWidget {
  final VideoConstantNumberCategory category;

  final String node;

  const CategoryVideosScreen({required this.node, required this.category});

  @override
  _CategoryVideosScreenState createState() => _CategoryVideosScreenState();
}

class _CategoryVideosScreenState extends ConsumerState<CategoryVideosScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: ListVideosWidget(
        categoryId: widget.category.id, // Fetch all videos
        node: widget.node,
      ),
    );
  }

  /// Builds the app bar with search & settings
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF13100E),
      title: PeerTubeTextWidget(text: widget.category.label),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.orange),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.orange),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.orange),
          onPressed: () {},
        ),
      ],
    );
  }
}
