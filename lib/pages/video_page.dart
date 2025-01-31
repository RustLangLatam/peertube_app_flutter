import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_app_flutter/utils.dart';
import 'package:river_player/river_player.dart';
import '../video_player_controller.dart';
import '../widgets/peertube_logo_widget.dart';

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
  final VideoPlayerControllerService _videoService =
      VideoPlayerControllerService();
  VideoDetails? _videoDetails;
  bool _isInitialized = false;

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

        // Use the playlistUrl of the video
        String uri = _videoDetails!.streamingPlaylists![0].playlistUrl!;

        // Initialize the video player
        await _videoService.initializePlayer(uri, _videoDetails!.isLive!);

        setState(() => _isInitialized = true);
      } else {
        throw 'Failed to load video';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing video: $e');
      }
    }
  }

  @override
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF13100E),
      appBar: AppBar(
        backgroundColor: Color(0xFF13100E),
        title: PeerTubeTextWidget(text: 'PeerTube Video'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isInitialized
          ? Column(
              children: [
                // Video Player
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(controller: _videoService.controller),
                ),

                // Video Details Section
                Expanded(
                  child: Container(
                    color: const Color(0xFF1A1A1A), // Dark background
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _videoDetails == null
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            children: [
                              // Video Title
                              Text(
                                _videoDetails!.name ?? "Unknown Title",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Video Metadata
                              Text(
                                "Published ${Utils.formatRelativeDate(_videoDetails?.publishedAt)} • ${_videoDetails!.views} views",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 8),

                              // Uploader Info
                              Row(
                                children: [
                                  AvatarUtils.buildAvatarFromVideoDetails(
                                      _videoDetails, widget.api.getHost),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4, // Máximo 40% del ancho
                                        child: Text(
                                          _videoDetails!.channel?.name ??
                                              "Unknown Channel",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Text(
                                        "By ${_videoDetails!.channel?.displayName ?? "Unknown"}",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  CustomButtons.subscribeButton()
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Video Description
                              buildExpandableText(
                                text: _videoDetails!.description ??
                                    "No descriptione",
                              ),
                              const SizedBox(height: 10),

                              // Video Details
                              Utils.buildDetailRow("Privacy",
                                  _videoDetails?.privacy?.label ?? "Public"),
                              Utils.buildDetailRow(
                                  "Origin",
                                  _videoDetails?.originallyPublishedAt
                                          ?.toIso8601String() ??
                                      "Unknown"),
                              Utils.buildDetailRow(
                                  "Originally Published",
                                  Utils.formatDateAsMMDDYYYY(
                                      _videoDetails?.publishedAt)),
                              Utils.buildLabelWidgetRow(
                                  label: "Category",
                                  child: Utils.buildDynamicButtonRow(
                                    buttonLabels:
                                        _videoDetails?.category != null
                                            ? [_videoDetails!.category!.label!]
                                            : ["Unknown"],
                                    onButtonPressed: (label) {
                                      // TODO: redirect to tag page
                                      print("label: $label");
                                    },
                                    // Custom splash color
                                  )),
                              Utils.buildDetailRow("License",
                                  _videoDetails?.licence?.label ?? "Unknown"),
                              Utils.buildDetailRow("Language",
                                  _videoDetails?.language?.label ?? "English"),
                              Utils.buildLabelWidgetRow(
                                  label: "Tags",
                                  child: Utils.buildDynamicButtonRow(
                                    buttonLabels:
                                        _videoDetails?.tags?.asList() ??
                                            ["Unknown"],
                                    onButtonPressed: (label) {
                                      // TODO: redirect to tag page
                                      print("label: $label");
                                    },
                                    // Custom splash color
                                  )),
                              Utils.buildDetailRow(
                                  "Duration",
                                  Utils.formatSecondsToMinSec(
                                      _videoDetails?.duration)),

                              const SizedBox(height: 12),

                              // Action Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomButtons.likeButton(),
                                  CustomButtons.dislikeButton(),
                                  CustomButtons.shareButton(),
                                  CustomButtons.downloadButton(),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
