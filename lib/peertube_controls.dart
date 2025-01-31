// import 'package:flutter/material.dart';
// import 'package:river_player/river_player.dart';
//
// class PeerTubeControls extends StatelessWidget {
//   final BetterPlayerController controller;
//
//   const PeerTubeControls({Key? key, required this.controller}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         // Bottom control bar
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             color: Colors.black54, // Semi-transparent black
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Play/Pause Button
//                 IconButton(
//                   icon: Icon(
//                     controller.isPlaying()! ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => controller.isPlaying()!
//                       ? controller.pause()
//                       : controller.play(),
//                 ),
//                 // Progress bar
//                 Expanded(
//                   child: BetterPlayerMaterialVideoProgressBar(controller),
//                 ),
//                 // Settings Button
//                 PopupMenuButton<String>(
//                   color: Colors.black87,
//                   icon: Icon(Icons.settings, color: Colors.white),
//                   itemBuilder: (context) => [
//                     _buildMenuItem("Speed", Icons.speed, () {
//                       // Open playback speed dialog
//                       controller.showSpeedDialog(context);
//                     }),
//                     _buildMenuItem("Subtitles", Icons.closed_caption, () {
//                       // Open subtitles selection
//                       controller.showSubtitlesSelectionDialog(context);
//                     }),
//                     _buildMenuItem("Quality", Icons.high_quality, () {
//                       // Open video quality selection
//                       controller.showQualitiesSelectionDialog(context);
//                     }),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   PopupMenuItem<String> _buildMenuItem(String text, IconData icon, VoidCallback onTap) {
//     return PopupMenuItem<String>(
//       child: ListTile(
//         leading: Icon(icon, color: Colors.white),
//         title: Text(text, style: TextStyle(color: Colors.white)),
//         onTap: onTap,
//       ),
//     );
//   }
// }
