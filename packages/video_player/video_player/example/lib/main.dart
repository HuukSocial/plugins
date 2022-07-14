// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

final headers = {
  'x-user-id': 'userId123',
  'x-room-id': '123',
};

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


  final m3u8IdsList1 = [5162, 4296, 6085, 5450, 4520, 5448, 5406, 6084, 4145, 5093];
  final m3u8IdsList2 = [5568, 5816, 5573, 5838, 4297, 5671, 5680, 4295, 5210, 4692];
  final m3u8IdsList3 = [5701, 4596, 5607, 5534, 5662, 3951, 5089, 5363, 4059, 4896];
  final m3u8IdsList4 = [5831, 6060, 4108, 5026, 4661, 5729, 5832, 5805, 4264, 4720];
  final m3u8IdsList5 = [3786, 5501, 4251, 4762, 5651, 5804, 5490, 4761, 5588, 4102];
  final m3u8IdsList7 = [5191, 4068, 4206, 5073];

  final mixedLinks = [
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8',
    'https://dudz6gr9lnpgd.cloudfront.net/output/nft-media/52db310c-3e9e-4887-a554-24cbc9df866d_3.mp4',
    'https://dudz6gr9lnpgd.cloudfront.net/output/nft-media/78549f62-6f87-4c8a-baf1-d4dc1266f007_2.mp4',
    'https://dudz6gr9lnpgd.cloudfront.net/output/nft-media/7176807a-1ba5-4c33-a8c2-6b806345772f_2.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/eaac50bc-83d2-4068-9785-a13c7159dd50_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/eaac50bc-83d2-4068-9785-a13c7159dd50_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/eaac50bc-83d2-4068-9785-a13c7159dd50_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/eaac50bc-83d2-4068-9785-a13c7159dd50_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/7eb3ff8c-e63e-4759-be47-466c9549ee92_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/7eb3ff8c-e63e-4759-be47-466c9549ee92_3.mp4',
    'https://d1mnr3vpricovd.cloudfront.net/output/nft-media/d6e1fb86-12bc-4406-8d31-84c72cdc70c2_3.mp4',
  ];

  final mp4IdsList1 = [
    '58/31cb1e27-0904-42d7-bea9-03c0d0a87098_3',
    '3e514ce3-b795-4540-965e-21cc3821e9f1_3',
    '54/0f6584a5-c23c-46d0-8273-1dcf79c51cbb_3',
    'f974a40b-452f-4231-9e81-ba6dbb35a764_3',
    '864ce3d8-1154-4226-8284-b294673b80d6_3',
    '8bab2cad-4ff9-4228-8d95-bc32a93ef6a4_3',
    '5ec94354-e0e1-44e0-aa0b-b32ddf694be3_3',
    '7f641f65-f570-4001-91b5-990770da7166_3',
    '5468a036-c823-4311-886e-933b6f74d480_3',
    '26d1965a-3955-42e0-ad09-badb6e64039f_3',
  ];
  final mp4IdsList2 = [
    '43492490-f4e5-4b65-9202-4f1419cc9498_3',
    'aa0f6612-481a-4d96-84f8-1fd553570bb1_3',
    '938f798c-eb42-495c-ada7-194c2a715a0b_3',
    'ffd4c933-e2b8-4752-ae21-0cff2d7f6af4_3',
    'ce930615-72dc-4fbe-805b-ccf4c26e483f_3',
    'c91fd9ca-5f91-492e-ab36-44250a68fcc7_3',
    '10a4e1e4-e1e9-48fc-a1ec-b62e09632c8e_3',
    'd941ecd5-e2f5-4aec-b62c-7e887c4deccc_3',
    '2ec17abd-f320-4e4e-9ffd-199b75da0af0_3',
    '59b0b6e2-4236-4a84-a75d-408178f4e8e6_3',
  ];
  final mp4IdsList3 = [
    '99516a29-a9e8-4436-b26c-dfffa9c7c0af_3',
    'a54d3fb2-1e05-42cc-a737-4f60465366e2_3',
    'a5856d73-8bb5-432c-86dc-20b3b6da8a07_3',
    '77066480-606c-41f4-a618-9680f6f18332_3',
    'f8560716-be96-414a-8993-0788bb8704ae_3',
    '8d319512-4563-4461-902a-67891ac6301f_3',
    '46053d4e-1065-4aa9-92ec-e349bf55e740_3',
    '447356ab-c5c2-421e-ad11-b2c22c5216f4_3',
    '3b22cd8d-48fb-435b-9fa5-812c896762c1_3',
    '5b65bf0e-125a-4810-95ea-fd09461d56fc_3',
  ];
  final mp4IdsList4 = [
    '57cb05d7-3b2a-4581-ab4b-352f5dd0c6bb_3',
    'e2dc805c-5da6-4d80-b995-98ef0d01ca69_3',
    'e5974d19-88cc-49b1-80b2-3848a4232c26_3',
    'f52fc790-33b7-435b-9082-0df10191f023_3',
    '80cb3024-23c4-4b3a-a144-cf58beda807c_3',
  ];

  String buildM3u8Url(int mediaId) {
    return 'https://d363fblnfweia.cloudfront.net/video/$mediaId/main.m3u8';
  }

  String buildMP4Url(String mediaId) {
    return 'https://dudz6gr9lnpgd.cloudfront.net/output/nft-media/$mediaId.mp4';
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
                child: Text("start predownload and cache 1"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList1.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 2"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList2.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 3"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList3.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 4"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList4.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 5"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList5.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 6"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: m3u8IdsList7.map((e) => buildM3u8Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              Wrap(
                children: m3u8IdsList1
                    .map(
                      (e) => TextButton(
                        child: Text("Preload $e"),
                        onPressed: () {
                          VideoPlayerCacheManager.predownloadAndCache(
                            urls: [
                              buildM3u8Url(e),
                            ],
                            shouldPreloadFirstSegment: true,
                            headers: headers,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              Wrap(
                children: m3u8IdsList1
                    .map(
                      (e) => TextButton(
                        child: Text("Open $e"),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerPage(url: buildM3u8Url(e)),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 80),
              TextButton(
                child: Text("start predownload mixed links"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: mixedLinks,
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              SizedBox(height: 80),

              TextButton(
                child: Text("start predownload and cache 1"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: mp4IdsList1.map((e) => buildMP4Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 2"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: mp4IdsList2.map((e) => buildMP4Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 3"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: mp4IdsList3.map((e) => buildMP4Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("start predownload and cache 4"),
                onPressed: () {
                  VideoPlayerCacheManager.predownloadAndCache(
                    urls: mp4IdsList4.map((e) => buildMP4Url(e)).toList(),
                    shouldPreloadFirstSegment: true,
                    headers: headers,
                  );
                },
              ),
              TextButton(
                child: Text("Open MP4"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlayerPage(url: buildMP4Url(mp4IdsList1.first)),
                    ),
                  );
                },
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
      httpHeaders: headers,
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
