import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:peertube_toolkit/peertube_toolkit.dart';

class CommentsPage extends StatefulWidget {
  final int videoId;
  final PeerTubeApiSdk api;

  const CommentsPage({
    super.key,
    required this.videoId,
    required this.api,
  });

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<VideoComment>? _comments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final apiComments = widget.api.getVideoCommentsApi();

    try {
      final id = ApiV1VideosOwnershipIdAcceptPostIdParameter(
          (p) => p..oneOf = OneOf.fromValue1(value: '${widget.videoId}'));

      final response = await apiComments.apiV1VideosIdCommentThreadsGet(
        id: id, // ✅ Pass videoId directly as an int
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments = response.data?.data?.toList() ?? [];
          _isLoading = false;
        });
      } else {
        throw 'Failed to load comments';
      }
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Comments", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comments == null || _comments!.isEmpty
              ? const Center(
                  child: Text("No comments yet.",
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _comments!.length,
                  itemBuilder: (context, index) {
                    final comment = _comments![index];
                    return _buildCommentTile(comment);
                  },
                ),
    );
  }

  Widget _buildCommentTile(VideoComment comment) {
    String formattedDate = "Unknown Date";
    if (comment.createdAt != null) {
      formattedDate = VideoDateUtils.formatDateAsMMDDYYYY(comment.createdAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              const Icon(Icons.account_circle, color: Colors.white, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.account?.displayName ?? "Unknown User",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Comment Text
          Text(
            comment.text ?? "No comment text",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),

          // Like & Reply Buttons
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.thumb_up, color: Colors.white70, size: 18),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.thumb_down,
                    color: Colors.white70, size: 18),
                onPressed: () {},
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text("Reply",
                    style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
