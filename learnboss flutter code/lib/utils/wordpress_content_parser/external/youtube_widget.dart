import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class YouTubeWidget {
  static String getIdFromUrl(String url, [bool trimWhitespaces = true]) {
    if (url.isEmpty) return "";

    if (trimWhitespaces) url = url.trim();

    url = url.replaceAll("%3A", ":");
    url = HtmlUnescape().convert(url);
    url = url.replaceAll("<!", "");
    url = url.replaceAll("\"", "");
    url = url.replaceAll("\n", "");

    for (var exp in _regexps) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1)!;
    }

    return "";
  }

  static final List<RegExp> _regexps = [
    RegExp(
        r"https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ];

  Widget buildWithVideoId(BuildContext context, String videoId) {
    return const Text("YouTubeWidget not implemented");
  }

  const YouTubeWidget();
}
