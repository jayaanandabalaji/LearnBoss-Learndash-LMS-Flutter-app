import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:isolate';
import 'dart:ui';

import 'package:chewie_audio/chewie_audio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/get.dart';
import 'package:learndash/utils/Constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils/wordpress_content_parser/external/embe_widget.dart';
import '../utils/wordpress_content_parser/wp_content.dart';

class HtmlWidget extends StatefulWidget {
  const HtmlWidget(this.content, {Key? key}) : super(key: key);
  final String content;

  @override
  State<HtmlWidget> createState() => _HtmlWidgetState();
}

class _HtmlWidgetState extends State<HtmlWidget> {
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];

      int progress = data[2];
      if (status.toString() == "DownloadTaskStatus(3)" && progress == 100) {
        String query = "SELECT * FROM task WHERE task_id='$id'";
        FlutterDownloader.loadTasksWithRawQuery(query: query);
        //if the task exists, open it
        FlutterDownloader.open(taskId: id);
      }
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.content.contains("-->")
        ? WPContent(
            widget.content,
            headingTextColor: Colors.black,
            paragraphTextColor: Colors.black,
            imageCaptionTextColor: Colors.black,
            textDirection: TextDirection.ltr,
            fontSize: 16.0,
            embedWidget: EmbedAppWidgets(),
            youtubeEmbedWidget: EmbedAppWidgets(),
          )
        : Html(data: widget.content);
  }
}

class EmbedAppWidgets extends EmbedWidget {
  @override
  Widget buildEmbedFromUrl(BuildContext context, String embedUrl) {
    if (isYoutube(embedUrl)) return youtubePlayer(context, embedUrl);
    if (isMp4(embedUrl)) return mp4VideoPlayer(context, embedUrl);
    if (isMp3(embedUrl)) return mp3AudioPlayer(context, embedUrl);
    if (isFile(embedUrl)) return fileDownloadWidget(context, embedUrl);
    return embedUrlWidget(context, embedUrl);
  }

  Widget embedUrlWidget(BuildContext context, String embedUrl) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: AspectRatio(
            aspectRatio: 16 / 9,
            child: InAppWebView(
                gestureRecognizers: {}..add(
                    Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer())),
                initialUrlRequest: URLRequest(url: Uri.parse(embedUrl)))));
  }

  String returnFileFormats() {
    String returnStr = "";
    for (String fileExt in Constants.supportedFileTypes) {
      if (fileExt != Constants.supportedFileTypes.last) {
        returnStr += "$fileExt|";
      } else {
        returnStr += fileExt;
      }
    }
    return returnStr;
  }

  bool isFile(String url) {
    String regEx = returnFileFormats();
    RegExp exp = RegExp('^.*.($regEx)\$');
    Iterable<RegExpMatch> matches = exp.allMatches(url);
    List<String> matchesStr = [];
    for (var match in matches) {
      matchesStr.add(url.substring(match.start, match.end));
    }
    if (matchesStr.isNotEmpty) {
      return true;
    }

    return false;
  }

  bool isMp4(String url) {
    if (url.contains(".mp4")) {
      return true;
    }
    return false;
  }

  bool isMp3(String url) {
    if (url.contains(".mp3")) {
      return true;
    }
    return false;
  }

  bool isYoutube(String url) {
    try {
      String? videoId;
      videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId != "") {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  final HtmlWidgetController _htmlController = Get.put(HtmlWidgetController());

  String getFileName(String fileUrl) {
    RegExp exp = RegExp(r'[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))');
    Iterable<RegExpMatch> matches = exp.allMatches(fileUrl);
    List<String> matchesStr = [];
    for (var match in matches) {
      matchesStr.add(fileUrl.substring(match.start, match.end));
    }
    if (matchesStr.isNotEmpty) {
      return matchesStr.first;
    }
    return "";
  }

  Widget fileDownloadWidget(BuildContext context, String embedUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () async {
          String path = await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOADS);

          await FlutterDownloader.enqueue(
            url: embedUrl,
            fileName: getFileName(embedUrl),
            savedDir: path,
            showNotification:
                true, // show download progress in status bar (for Android)
            openFileFromNotification:
                true, // click on notification to open downloaded file (for Android)
          );
        },
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_new,
              color: Colors.blue,
              size: 15,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              getFileName(embedUrl),
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            )
          ],
        )),
      ),
    );
  }

  Widget mp3AudioPlayer(BuildContext context, String embedUrl) {
    if (_htmlController.audioPlayerControllers[embedUrl] == null) {
      _htmlController.audioPlayerControllers[embedUrl] = ChewieAudioController(
        videoPlayerController: VideoPlayerController.network(embedUrl),
        autoPlay: false,
        looping: true,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ChewieAudio(
        controller: _htmlController.audioPlayerControllers[embedUrl]!,
      ),
    );
  }

  Widget mp4VideoPlayer(BuildContext context, String embedUrl) {
    if (_htmlController.videoPlayerControllers[embedUrl] == null) {
      _htmlController.videoPlayerControllers[embedUrl] = MeeduPlayerController(
        controlsStyle: ControlsStyle.primary,
      );
      _htmlController.videoPlayerControllers[embedUrl]!.setDataSource(
        DataSource(
          type: DataSourceType.network,
          source: embedUrl,
        ),
        autoplay: false,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: MeeduVideoPlayer(
          controller: _htmlController.videoPlayerControllers[embedUrl]!,
        ),
      ),
    );
  }

  Widget youtubePlayer(BuildContext context, String embedUrl) {
    return YoutubePlayer(
      bottomActions: [
        RemainingDuration(),
        ProgressBar(isExpanded: true),
        const PlaybackSpeedButton(),
        IconButton(
          icon: const Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: () async {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            await Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => SafeArea(
                      child: YoutubePlayer(
                        controller: YoutubePlayerController(
                            initialVideoId:
                                YoutubePlayer.convertUrlToId(embedUrl) ?? "",
                            flags: const YoutubePlayerFlags(
                              autoPlay: true,
                            )),
                        bottomActions: [
                          RemainingDuration(),
                          ProgressBar(isExpanded: true),
                          const PlaybackSpeedButton(),
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              Get.back();
                            },
                          )
                        ],
                      ),
                    )));
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          },
        )
      ],
      controller: YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(embedUrl) ?? "",
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ),
      ),
    );
  }
}

class HtmlWidgetController extends GetxController {
  Map<String, MeeduPlayerController> videoPlayerControllers = {};
  Map<String, ChewieAudioController> audioPlayerControllers = {};
}
