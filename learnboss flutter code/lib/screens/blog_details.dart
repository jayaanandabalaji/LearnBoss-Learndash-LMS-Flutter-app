import 'package:android_path_provider/android_path_provider.dart';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/blogs.dart';
import '../utils/Constants.dart';

class BlogDetail extends StatefulWidget {
  final isOthers;
  final Blogs blog;
  const BlogDetail({Key? key, required this.blog, this.isOthers = false})
      : super(key: key);

  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  bool adloaded = false;
  var unescape = HtmlUnescape();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    if (Constants.showAds) {
      _createInterstitialAd();
    }
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {});
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    send!.send([id, status, progress]);
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Constants.interstitialUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            if (!adloaded) {
              _showInterstitialAd();
              adloaded = true;
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Share.share(widget.blog.link);
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(
                height:
                    (widget.isOthers) ? Get.height * 0.8 : Get.height * 0.88,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      unescape.convert(widget.blog.title.rendered),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "By".tr +
                          widget.blog.embedded["author"][0]["name"]
                              .replaceAll("@gmail.com", ""),
                      style: TextStyle(
                          color: Constants.primaryColor, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "${"Last updated on".tr} ${widget.blog.modified.substring(0, 10)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    (widget.blog.embedded["wp:featuredmedia"] != null)
                        ? ExtendedImage.network(
                            widget.blog.embedded["wp:featuredmedia"][0]
                                ["source_url"],
                            fit: BoxFit.cover)
                        : ExtendedImage.asset("assets/placeholder.jpg",
                            fit: BoxFit.cover),
                    const SizedBox(
                      height: 15,
                    ),
                    //  html_content.html_widget(widget.blog.content.rendered)
                    Html(
                      data: widget.blog.content.rendered,
                    )
                  ],
                )),
            if (widget.isOthers)
              Expanded(
                  child: Center(
                child: MaterialButton(
                    color: Constants.primaryColor,
                    textColor: Colors.white,
                    minWidth: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text("Download"),
                    onPressed: () async {
                      var name = widget.blog.details["file_file-link"][0]
                          .split('/')
                          .last;
                      final dir =
                          await _prepareSaveDir(); //From path_provider package
                      var localPath = "$dir/$name";
                      final savedDir = Directory(localPath);
                      await savedDir
                          .create(recursive: true)
                          .then((value) async {
                        await FlutterDownloader.enqueue(
                          url: widget.blog.details["file_file-link"][0],
                          fileName: name,
                          savedDir: localPath,
                          showNotification: true,
                          openFileFromNotification: true,
                        );
                      });
                    }),
              ))
          ],
        ));
  }

  Future<String> _prepareSaveDir() async {
    var localPath = (await _findLocalPath())!;
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return localPath;
  }

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }
}
