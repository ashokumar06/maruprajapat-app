import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme_config.dart';

class InlineYoutubePlayer extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final BorderRadius borderRadius;

  const InlineYoutubePlayer({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<InlineYoutubePlayer> createState() => _InlineYoutubePlayerState();
}

class _InlineYoutubePlayerState extends State<InlineYoutubePlayer> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant InlineYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.close();
      _initializeController();
    }
  }

  void _initializeController() {
    _videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);
    if (_videoId == null || _videoId!.isEmpty) {
      _controller = null;
      return;
    }

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: true,
        strictRelatedVideos: true,
        origin: 'https://www.youtube.com',
      ),
    );
    
    _controller!.loadVideoById(videoId: _videoId!);
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: widget.borderRadius,
        ),
        child: const Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 52,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: widget.borderRadius,
          child: YoutubePlayer(
            controller: _controller!,
            aspectRatio: widget.aspectRatio,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              final url = Uri.parse(widget.videoUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new, size: 16, color: ThemeConfig.primary),
            label: const Text(
              'YouTube पर देखें',
              style: TextStyle(fontSize: 12, color: ThemeConfig.primary, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: ThemeConfig.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
