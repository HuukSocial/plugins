// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: FirstPage(),
    ),
  );
}

class FirstPage extends StatefulWidget {
  FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final listId1 = [
    // 6499,
    6406,
    6378,
    6301,
    6248,
    6247,
    6246,
    6244,
    6213,
    6211,
    6202,
  ];

  final listId2 = [
    6085,
    6084,
    5766,
    5671,
    5670,
    5669,
    5668,
    5613,
    5611,
    5608,
  ];

  final listId3 = [
    5607,
    5605,
    5600,
    5593,
    5592,
    5591,
    5564,
    5559,
    5481,
    5473,
  ];

  final listId4 = [
    5467,
    5466,
    5432,
    5423,
    5423,
    5423,
    5423,
    5423,
    5423,
    5423,
  ];

  final listId5 = [
    5390,
    5381,
    5380,
    5210,
    5191,
    5190,
    5150,
    5133,
    4818,
    4817,
  ];

  final listId6 = [
    4566,
    4531,
    4530,
    4529,
    4460,
  ];

  String buildMediaUrl(int mediaId) {
    return 'https://du1cqvp35pinp.cloudfront.net/video/$mediaId/main.m3u8';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextButton(
                child: Text("start predownload and cache"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId1.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 2"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId2.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 3"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId3.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 4"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId4.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 5"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId5.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 6"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: listId6.map((e) => buildMediaUrl(e)).toList(),
                    shouldPreloadFirstSegment: true,
                  );
                },
              ),
              Wrap(
                children: listId1
                    .map(
                      (e) => TextButton(
                        child: Text("Preload $e"),
                        onPressed: () {
                          VideoPlayerCacheManager.predownloadAndCache(
                            urls: [
                              buildMediaUrl(e),
                            ],
                            shouldPreloadFirstSegment: true,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              Wrap(
                children: listId1
                    .map(
                      (e) => TextButton(
                        child: Text("Open $e"),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerPage(url: buildMediaUrl(e)),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String url;

  const PlayerPage({Key? key, required this.url}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initPlayer() async {
    _controller = VideoPlayerController.network(
      widget.url,
      // closedCaptionFile: _loadCaptions(),
      // videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      resolutionConfig: {
        'maxWidth': 3840.0,
        'maxHeight': 3840.0,
      },
    );

    _controller.addListener(() {
      setState(() {});
    });
    await _controller.setLooping(true);
    await _controller.initialize();
    await _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(padding: const EdgeInsets.only(top: 20.0)),
              const Text('With remote mp4'),
              Container(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      _ControlsOverlay(controller: _controller),
                      VideoProgressIndicator(_controller, allowScrubbing: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _exampleCaptionOffsets = [
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration(milliseconds: 0),
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (context) {
              return [
                for (final offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
