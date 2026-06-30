import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  bool _didTryUnmute = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant InlineYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _initializeController();
    }
  }

  void _initializeController() {
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (_videoId == null || _videoId!.isEmpty) {
      _controller = null;
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
        enableCaption: false,
        useHybridComposition: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
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

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: widget.aspectRatio,
          showVideoProgressIndicator: true,
          progressIndicatorColor: ThemeConfig.primary,
          onReady: () {
            _controller?.play();
            if (!_didTryUnmute) {
              _didTryUnmute = true;
              Future.delayed(const Duration(milliseconds: 900), () {
                if (mounted) {
                  _controller?.unMute();
                }
              });
            }
          },
        ),
      ),
    );
  }
}
