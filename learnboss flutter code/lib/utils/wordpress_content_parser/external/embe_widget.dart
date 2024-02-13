import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class EmbedWidget {
  static String getIdFromUrl(String url, [bool trimWhitespaces = true]) {
    if (url.isEmpty) return "";

    url = url.replaceAll("%3A", ":");
    url = HtmlUnescape().convert(url);
    url = url.replaceAll("<!", "");
    url = url.replaceAll("\"", "");
    url = url.replaceAll("\n", "");

    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(url);
    List<String> urls = [];
    for (var match in matches) {
      urls.add(url.substring(match.start, match.end));
    }

    if (urls.isNotEmpty) {
      return urls.first;
    }
    return "";
  }

  Widget buildEmbedFromUrl(BuildContext context, String embedUrl) {
    return const Text("EmbedWidget not implemented");
  }

  const EmbedWidget();
}
