import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';

import '../notifiers/video_state_notifier.dart';

class VideoPageTow extends ConsumerWidget {
  final Video video;

  const VideoPageTow({super.key, required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter example')),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final data = ref.watch(videoDetailsStateProvider);
            return data.when(
              data: (video) {
                return Text(video.toString());
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // The read method is a utility to read a provider without listening to it
        onPressed: () => ref
            .read(videoDetailsStateProvider.notifier)
            .fetchVideo(id: '${video.uuid}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
