import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape.dart';

class HearthisAtWidget {
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
        r"https:\/\/(?:app\.|m\.)?hearthis\.at\/embed\/([_\-a-zA-Z0-9]{1,20})\/.*$"),
  ];

  Widget buildWithTrackId(BuildContext context, String trackId) {
    return const Text("HearthisAtWidget not implemented");
  }

  const HearthisAtWidget();
}
