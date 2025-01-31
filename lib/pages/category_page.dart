// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/widgets/list_videos_widget.dart';

import '../widgets/peertube_logo_widget.dart';

class CategoryVideosScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  final PeerTubeApiSdk api;

  const CategoryVideosScreen({ required this.api, required this.categoryId,required this.categoryName});

  @override
  _CategoryVideosScreenState createState() => _CategoryVideosScreenState();
}

class _CategoryVideosScreenState extends State<CategoryVideosScreen> {

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
        categoryId: widget.categoryId, // Fetch all videos
        api: widget.api,
      ),
    );
  }

  /// Builds the app bar with search & settings
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF13100E),
      title: PeerTubeTextWidget(text: widget.categoryName),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
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
