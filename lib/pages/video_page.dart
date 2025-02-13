import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/pages/tag_page.dart';
import 'package:peertube_app_flutter/utils/export.dart';
import 'package:river_player/river_player.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/api_provider.dart';
import '../transitions/custom_page_route.dart';
import '../video_player_controller/peertube_player.dart';
import '../widgets/expandable_text_widget.dart';
import '../widgets/license_badge.dart';
import '../widgets/peertube_logo_widget.dart';
import '../widgets/unsupported_format_widget.dart';
import 'category_page.dart';
import 'channel_page.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String node;
  final Video video;

  const VideoPlayerScreen({
    super.key,
    required this.node,
    required this.video,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  GlobalKey _videoPlayerKey = GlobalKey();

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
    try {
      final api = ref.read(videoApiProvider);

      final response = await api.getVideo(
        id: ApiV1VideosOwnershipIdAcceptPostIdParameter(
          (p) => p..oneOf = OneOf.fromValue1(value: '${widget.video.uuid}'),
        ),
      );

      if (response.statusCode == 200) {
        _videoDetails = response.data;

        // Run video initialization in the background
        Future.microtask(() async {
          await _videoPlayer.initializePlayer(_videoPlayerKey, _videoDetails,
              nodeUrl: widget.node);
        });

        int elapsedTime = 0;
        // Monitor initialization state without blocking
        while (!_videoPlayer.isVideoInitialized) {
          if (elapsedTime == 500) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 100));
          elapsedTime += 100;
        }

        // If initialized or timeout reached, update state
        //   if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // }
      } else {
        throw 'Failed to load video: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing video: $e');
      }
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
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
        title: const PeerTubeTextWidget(),
        leading: const PeerTubeLogoWidget(),
        actions: [
          Padding(
              padding: const EdgeInsets.only(left: 14.0, top: 10, bottom: 10),
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: Colors.orange),
                onPressed: () => Navigator.of(context).pop(),
              ))
        ],
      ),
      body: _hasError
          ? const UnsupportedFormatWidget() // Error widget
          : _buildVideoContent(), // Show shimmer while loading
    );
  }

  /// 📌 Builds the actual video UI when loaded
  Widget _buildVideoContent() {
    final video = widget.video;

    final thumbnailURL = VideoUtils.getVideoThumbnailUrl(video, widget.node);

    return Column(
      children: [
        // 🎬 Video Player

        _isInitialized
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                    controller: _videoPlayer.controller!, key: _videoPlayerKey),
              )
            : UIUtils.buildHeroVideoThumbnail(
                thumbnailURL: thumbnailURL ?? '',
                useRoundedCorners: false,
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
                VideoUtils.buildVideoTitle(video.name),
                const SizedBox(height: 4),

                // 📅 Video Metadata (Published Date & Views)
                Row(
                  children: [
                    Text(
                      "Published ${VideoDateUtils.formatRelativeDate(video.publishedAt)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle,
                        size: 4, color: Colors.orange), // Bullet
                    const SizedBox(width: 6),
                    VideoUtils.buildViewCount(video.views),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle,
                        size: 4, color: Colors.orange), // Bullet
                    const SizedBox(width: 4),

                    if (video.licence != null)
                      // License Badge with overflow ellipsis
                      Flexible(
                        child: LicenseBadge(licenseLabel: video.licence!),
                      ),
                  ],
                ),
                const SizedBox(height: 15),

                // 🎯 Action Buttons (Like, Dislike, Share, Download)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Spacer(),
                    ButtonsUtils.likeButton(likes: video.likes),
                    ButtonsUtils.dislikeButton(dislikes: video.dislikes),
                    ButtonsUtils.shareButton(onPressed: () {
                      // TODO: Share video
                      UIUtils.showTemporaryBottomDialog(
                          context, "Share video no implemented yet...");
                    }),
                    ButtonsUtils.downloadButton(onPressed: () {
                      // TODO: Download video
                      UIUtils.showTemporaryBottomDialog(
                          context, "Download video no implemented yet...");
                    }),
                  ],
                ),
                const Divider(height: 20, color: Colors.grey),

                // 👤 Uploader Info
                Row(
                  children: [
                    // Channel Avatar
                    GestureDetector(
                      onTap: () {
                        if (_videoPlayer.isVideoActive) {
                          _videoPlayer.controller!.pause();
                          Navigator.push(
                            context,
                            CustomPageRoute.slide(ChannelScreen(
                                channel: video.channel!, node: widget.node)),
                          ).whenComplete(() {
                            _videoPlayer.controller!.play();
                          });
                        }
                      }, // ✅ Clickable Avatar
                      child: AvatarUtils.buildAvatarFromVideoDetails(
                          video, widget.node),
                    ),
                    const SizedBox(width: 8),

                    // Channel Name & "By" Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            VideoUtils.extractNameOrDisplayName(video,
                                node: widget.node),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              // fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            "By ${VideoUtils.extractNameOrDisplayName(video, prioritizeChannel: false)}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 📌 Subscribe Button
                    ButtonsUtils.subscribeButton(onPressed: () {
                      // TODO: Subscribe to channel
                      UIUtils.showTemporaryBottomDialog(context,
                          "Subscribe to channel no implemented yet...");
                    }),
                  ],
                ),
                const SizedBox(height: 10),

                // 📜 Video Description (Expandable)
                buildExpandableText(
                  text: video.truncatedDescription ?? "No description",
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
    final video = widget.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UIUtils.buildDetailRow("Privacy", video.privacy?.label ?? "Public"),
        UIUtils.buildDetailRow("Origin", "Unknown"),
        UIUtils.buildDetailRow("Originally Published",
            VideoDateUtils.formatDateAsMMDDYYYY(video.publishedAt)),
        UIUtils.buildLabelWidgetRow(
            label: "Category",
            child: UIUtils.buildDynamicButtonRow(
              buttonLabels: video.category != null
                  ? [video.category!.label!]
                  : ["Unknown"],
              onButtonPressed: (label) {
                if (_videoPlayer.isVideoActive) {
                  _videoPlayer.controller!.pause();
                  Navigator.push(
                    context,
                    CustomPageRoute.slide(CategoryVideosScreen(
                        category: video.category!, // Fetch all videos
                        node: widget.node)),
                  ).whenComplete(() {
                    _videoPlayer.controller!.play();
                  });
                }
              },
            )),
        UIUtils.buildDetailRow("Language", video.language?.label ?? "English"),
        UIUtils.buildLabelWidgetRow(
          label: "Tags",
          child: UIUtils.buildDynamicButtonRow(
            buttonLabels: _videoDetails?.tags?.asList() ?? ["Unknown"],
            onButtonPressed: (selectedTag) {
              if (_videoPlayer.isVideoActive) {
                _videoPlayer.controller!.pause();
                Navigator.push(
                  context,
                  CustomPageRoute.slide(
                      TagVideosScreen(tag: selectedTag, node: widget.node)),
                ).whenComplete(() {
                  _videoPlayer.controller!.play();
                });
              }
            },
          ),
        ),
        UIUtils.buildDetailRow(
            "Duration", VideoDateUtils.formatSecondsToMinSec(video.duration)),
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
