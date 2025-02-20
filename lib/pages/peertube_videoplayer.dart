import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PeerTubeVideoPlayer extends StatefulWidget {
  final String embedUrl;
  final String videoId;
  final PeertubeVideoController videoController;
  final double? height;
  const PeerTubeVideoPlayer(
      {super.key,
      required this.embedUrl,
      required this.videoController,
      required this.videoId,
      this.height});

  @override
  _PeerTubeVideoPlayerState createState() => _PeerTubeVideoPlayerState();
}

class _PeerTubeVideoPlayerState extends State<PeerTubeVideoPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InAppWebView(
            initialData: InAppWebViewInitialData(data: _getHtml()),
            // initialUrlRequest: URLRequest(url: WebUri(widget.embedUrl)),
            // initialOptions: InAppWebViewGroupOptions(
            //   crossPlatform: InAppWebViewOptions(
            //     debuggingEnabled: true,
            //   ),
            // ),
            shouldOverrideUrlLoading: (controller, action) async {
              return NavigationActionPolicy.ALLOW;
            },
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              // initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              iframeAllow:
                  "camera; microphone", // for camera and microphone permissions
              iframeAllowFullscreen: true, // if you need fullscreen support
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              widget.videoController.init(controller);
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT);
            },
            onLoadStop: (controller, url) {
              debugPrint(
                  "[2025-01-03 17:33:18][widget.autoplay] ${widget.videoController.autoplay}");
            },
            onLoadStart: (controller, url) async {
              // Handle autoplay if required
              debugPrint(
                  "[2025-01-03 17:02:22][navigationRequest.request.url] ${url.toString()}");
            },
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     IconButton(
        //       icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        //       onPressed: () async {
        //         debugPrint(
        //             "[2025-01-06 09:25:17][widget.videoController.webViewController] ${widget.videoController.webViewController}");
        //         if (_isPlaying) {
        //           await widget.videoController.pause();
        //         } else {
        //           await widget.videoController.play();
        //         }
        //         setState(() {
        //           _isPlaying = !_isPlaying;
        //         });
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }

  _getHtml() {
    // return "<h1>hello</h1>";
    // final primaryColor = Theme.of(context).primaryColor;
    return '''
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Document</title>
                <script src="https://unpkg.com/@peertube/embed-api/build/player.min.js"></script>

              <style>
                .lds-ring div{box-sizing:border-box}.lds-ring{display:inline-block;position:relative;width:80px;height:80px}.lds-ring div{box-sizing:border-box;display:block;position:absolute;width:64px;height:64px;margin:8px;border:6px solid #9f9f9f;border-radius:50%;animation:lds-ring 1.2s cubic-bezier(.5,0,.5,1) infinite;border-color:#9f9f9f transparent transparent transparent}.lds-ring div:nth-child(1){animation-delay:-.45s}.lds-ring div:nth-child(2){animation-delay:-.3s}.lds-ring div:nth-child(3){animation-delay:-.15s}@keyframes lds-ring{0%{transform:rotate(0)}100%{transform:rotate(360deg)}}.centered{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);transform:-webkit-translate(-50%,-50%);transform:-moz-translate(-50%,-50%);transform:-ms-translate(-50%,-50%)}
              </style>  
            </head>

            <body style="margin:0;">
                <div class="lds-ring centered" id="loadingContainer">
                    <div></div>
                    <div></div>
                    <div></div>
                    <div></div>
                </div>

                <div style="position: relative; padding:0px">
                    <iframe title="Snaptik.app_7313919503505607954" 
                      width="100%" 
                      height="${widget.height}px"
                        allow="autoplay" 
                        src="https://peertube.orderi.co/videos/embed/${widget.videoId}?api=1&loop=1&autoplay=${widget.videoController.autoplay}&title=0&warningTitle=0&controlBar=1&peertubeLink=0"
                        frameborder="0" allowfullscreen="" sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                        style="position: absolute; inset: 0px; padding:0px;"></iframe>
                </div>
                <script>
                    const PeerTubePlayer = window['PeerTubePlayer']

                    let player = new PeerTubePlayer(document.querySelector('iframe'))
                    console.log('====== test_peer.html: 1735901071470, player ', player);
                    // await player.ready
                    (async function () {
                        await player.ready
                        document.getElementById("loadingContainer").remove()
                        // player.play()
                    })()       
                  window.addEventListener(
                    "play",
                    (event) => {
                      player.play()
                    },
                    false,
                  );
                  window.addEventListener(
                    "pause",
                    (event) => {
                      player.pause()
                    },
                    false,
                  );
                </script>
            </body>

            </html>
            ''';
  }
}

class PeertubeVideoController {
  late InAppWebViewController webViewController;
  final String autoplay;

  PeertubeVideoController({required this.autoplay});

  /// intialize webview controller
  init(InAppWebViewController controller) {
    webViewController = controller;
    debugPrint("[2025-01-06 09:26:48][webViewController] ${webViewController}");
    // webViewController.evaluateJavascript(source: '''

    // ''');
  }

  /// Play video
  Future<dynamic> play() {
    debugPrint("[2025-01-06 13:22:39][play] ");
    return webViewController.evaluateJavascript(source: '''
        document.querySelector("video").play()
        console.log('====== peertube_videoplayer.dart: 1736133506533, document.querySelector("video") ',document.querySelector("video"));
        window.dispatchEvent( new CustomEvent("play"));
    ''');
  }

  /// Play video
  Future<dynamic> pause() {
    return webViewController.evaluateJavascript(source: '''
      document.querySelector("video").pause()
      player.pause()
      window.dispatchEvent( new CustomEvent("pause"));
    ''');
  }
}
