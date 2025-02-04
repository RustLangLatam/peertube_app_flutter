import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/utils/export.dart';
import 'package:river_player/river_player.dart';
import 'package:shimmer/shimmer.dart';
import '../video_player_controller/player_controller_service.dart';
import '../widgets/expandable_text_widget.dart';
import '../widgets/license_badge.dart';
import '../widgets/peertube_logo_widget.dart';
import '../widgets/unsupported_format_widget.dart';

class HlsVideoPlayerPage extends StatefulWidget {
  final int videoId;
  final PeerTubeApiSdk api;

  const HlsVideoPlayerPage({
    super.key,
    required this.videoId,
    required this.api,
  });

  @override
  _HlsVideoPlayerPageState createState() => _HlsVideoPlayerPageState();
}

class _HlsVideoPlayerPageState extends State<HlsVideoPlayerPage> {
  final PeerTubePlayer _videoPlayer = PeerTubePlayer();
  VideoDetails? _videoDetails;
  bool _isInitialized = false;
  bool _hasError = false; // Track error state

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final apiVideos = widget.api.getVideoApi();

    try {
      final id = ApiV1VideosOwnershipIdAcceptPostIdParameter(
          (p) => p..oneOf = OneOf.fromValue1(value: '${widget.videoId}'));

      var response = await apiVideos.getVideo(id: id);
      if (response.statusCode == 200) {
        _videoDetails = response.data;

        setState(() {
          _isInitialized = true;
        });

        // Initialize the video player
        await _videoPlayer.initializePlayer(_videoDetails);
      } else {
        throw 'Failed to load video: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing video: $e');
      }
      setState(() {
        _hasError = true; // Set error state
      });
    }
  }

  @override
  void dispose() {
    _videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const PeerTubeTextWidget(text: "PeerTube Video"),
        leading: Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )),
      ),
      body: _hasError
          ? const UnsupportedFormatWidget() // Error widget
          : _isInitialized
              ? _buildVideoContent()
              : _buildShimmerLoading(), // Show shimmer while loading
    );
  }

  /// 📌 Builds the actual video UI when loaded
  Widget _buildVideoContent() {
    return Column(
      children: [
        // 🎬 Video Player
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _videoPlayer.controller),
        ),

        // 📌 Video Details Section
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2D2A27),
                  Color(0xFF22201E),
                  Color(0xFF1A1A1A),
                ],
                stops: [0.0, 0.3, 0.8],
              ),
            ),

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              children: [
                // 🎥 Video Title
                TextUtils.buildVideoTitle(_videoDetails!.name),
                const SizedBox(height: 4),

                // 📅 Video Metadata (Published Date & Views)
                Row(
                  children: [
                    Text(
                      "Published ${VideoDateUtils.formatRelativeDate(_videoDetails?.publishedAt)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle,
                        size: 4, color: Colors.grey), // Bullet
                    const SizedBox(width: 6),
                    VideoUtils.buildViewCount(_videoDetails?.views),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle,
                        size: 4, color: Colors.grey), // Bullet
                    const SizedBox(width: 4),

                    if (_videoDetails!.licence != null)
                    // License Badge with overflow ellipsis
                    Flexible(
                      child:
                          LicenseBadge(licenseLabel: _videoDetails!.licence!),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 🎯 Action Buttons (Like, Dislike, Share, Download)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Spacer(),
                    ButtonsUtils.likeButton(likes: _videoDetails?.likes),
                    ButtonsUtils.dislikeButton(
                        dislikes: _videoDetails?.dislikes),
                    ButtonsUtils.shareButton(),
                    ButtonsUtils.downloadButton(),
                  ],
                ),
                const Divider(height: 20, color: Colors.grey),

                // 👤 Uploader Info
                Row(
                  children: [
                    // Channel Avatar
                    AvatarUtils.buildAvatarFromVideoDetails(
                        _videoDetails, widget.api.getHost),
                    const SizedBox(width: 8),

                    // Channel Name & "By" Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            VideoUtils.extractDisplayName(_videoDetails!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            "By ${VideoUtils.extractDisplayName(_videoDetails!, prioritizeChannel: false)}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // 📌 Subscribe Button
                    ButtonsUtils.subscribeButton(),
                  ],
                ),
                const SizedBox(height: 10),

                // 📜 Video Description (Expandable)
                buildExpandableText(
                  text: _videoDetails!.description ?? "No description",
                ),
                const SizedBox(height: 15),

                // 🔍 Additional Video Details
                _buildVideoDetailsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 📌 Builds extra video details (Category, License, Language, Tags, Duration)
  Widget _buildVideoDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UIUtils.buildDetailRow(
            "Privacy", _videoDetails?.privacy?.label ?? "Public"),
        UIUtils.buildDetailRow(
            "Origin",
            _videoDetails?.originallyPublishedAt?.toIso8601String() ??
                "Unknown"),
        UIUtils.buildDetailRow("Originally Published",
            VideoDateUtils.formatDateAsMMDDYYYY(_videoDetails?.publishedAt)),
        UIUtils.buildLabelWidgetRow(
            label: "Category",
            child: UIUtils.buildDynamicButtonRow(
              buttonLabels: _videoDetails?.category != null
                  ? [_videoDetails!.category!.label!]
                  : ["Unknown"],
              onButtonPressed: (label) {
                // TODO: Redirect to category
                print("Category clicked: $label");
              },
            )),
        UIUtils.buildDetailRow(
            "Language", _videoDetails?.language?.label ?? "English"),
        UIUtils.buildLabelWidgetRow(
            label: "Tags",
            child: UIUtils.buildDynamicButtonRow(
              buttonLabels: _videoDetails?.tags?.asList() ?? ["Unknown"],
              onButtonPressed: (label) {
                // TODO: Redirect to tag page
                print("Tag clicked: $label");
              },
            )),
        UIUtils.buildDetailRow("Duration",
            VideoDateUtils.formatSecondsToMinSec(_videoDetails?.duration)),
      ],
    );
  }

  /// 📌 Builds a ghost UI using Shimmer while loading
  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Fake Video Thumbnail
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
          ),
        ),

        // Fake Details
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2D2A27),
                  Color(0xFF22201E),
                  Color(0xFF1A1A1A),
                ],
                stops: [0.0, 0.3, 0.8],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: ListView(
                children: [
                  // Fake Video Title
                  Container(
                    width: double.infinity,
                    height: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 11),

                  // Fake Video Metadata
                  Row(
                    children: [
                      Container(width: 122, height: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 4),
                      const SizedBox(width: 6),
                      Container(width: 52, height: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 4, color: Colors.grey),
                      const SizedBox(width: 8),
                      Container(
                        width: 71,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),

                  // Fake Action Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      ButtonsUtils.likeButton(),
                      ButtonsUtils.dislikeButton(),
                      ButtonsUtils.shareButton(),
                      ButtonsUtils.downloadButton(),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.grey),
                  const SizedBox(height: 6),

                  // Fake Uploader Info
                  Row(
                    children: [
                      // Fake Avatar
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Fake Channel Name and Display Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 120, height: 14, color: Colors.white),
                          const SizedBox(height: 4),
                          Container(width: 80, height: 12, color: Colors.white),
                        ],
                      ),
                      const Spacer(),

                      // Fake Subscribe Button
                      Container(
                        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        width: 107,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fake Video Description
                  Container(
                      width: double.infinity, height: 12, color: Colors.white),
                  const SizedBox(height: 37),

                  // Fake Video Details
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow(),
                  _buildShimmerDetailRow()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper to build a shimmering detail row
  Widget _buildShimmerDetailRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.2),
      child: Row(
        children: [
          Container(width: 80, height: 13, color: Colors.white),
          const SizedBox(width: 8),
          Container(width: 120, height: 13, color: Colors.white),
        ],
      ),
    );
  }
}
