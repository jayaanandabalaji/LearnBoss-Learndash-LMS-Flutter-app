import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/Paragraph.dart';

// Supported parsers for the content
final List<Function> _contentParsers = [
  _parseSuperscript,
  _parseSubscript,
  _parseStrongTags,
  _parseATags,
];

// Parse heading text
Paragraph parseHeadingHTML(String content,
    {bool isArabic = false,
    TextAlign textAlign = TextAlign.left,
    String arabicFontFamily = "",
    String fontFamily = "",
    double baseFontSize = 16.0}) {
  var data = [TextSpan(text: content)];
  for (var p in _contentParsers) {
    data = p(data, baseFontSize);
  }
  return Paragraph.heading(content, _decodeHTML(data),
      isArabic ? arabicFontFamily : fontFamily, textAlign);
}

// Parse paragraph text
Paragraph parseParagraphHTML(String content,
    {bool isArabic = false,
    TextAlign textAlign = TextAlign.left,
    String arabicFontFamily = "",
    String fontFamily = "",
    double baseFontSize = 16.0}) {
  var data = [TextSpan(text: content)];
  for (var p in _contentParsers) {
    data = p(data, baseFontSize);
  }
  return Paragraph.text(content, _decodeHTML(data),
      isArabic ? arabicFontFamily : fontFamily, textAlign);
}

// Parse quote text
Paragraph parseQuoteHTML(String content,
    {bool isArabic = false,
    TextAlign textAlign = TextAlign.left,
    String arabicFontFamily = "",
    String fontFamily = "",
    double baseFontSize = 16.0}) {
  var data = [TextSpan(text: content)];
  for (var p in _contentParsers) {
    data = p(data, baseFontSize);
  }
  return Paragraph.quote(content, _decodeHTML(data),
      isArabic ? arabicFontFamily : fontFamily, textAlign);
}

// Parse list text
Paragraph parseListHTML(String content,
    {bool isArabic = false,
    TextAlign textAlign = TextAlign.left,
    String arabicFontFamily = "",
    String fontFamily = "",
    double baseFontSize = 16.0}) {
  var data = [TextSpan(text: content)];
  for (var p in _contentParsers) {
    data = p(data, baseFontSize);
  }
  return Paragraph.text(content, _decodeHTML(data),
      isArabic ? arabicFontFamily : fontFamily, textAlign);
}

// Parse image caption text
List<TextSpan> parseFigureCaptionHTML(String content,
    {double baseFontSize = 12.0}) {
  try {
    var data = [TextSpan(text: content)];
    for (var p in _contentParsers) {
      data = p(data, baseFontSize);
    }
    return _decodeHTML(data);
  } catch (exception) {
    return [];
  }
}

// Parse superscript tags <sup></sup>
List<TextSpan> _parseSuperscript(List<TextSpan> content, double baseFontSize) {
  const String tag = "<sup>";
  const String endTag = "</sup>";
  const int tagLength = 5;
  const int endTagLength = 6;

  List<TextSpan> spans = [];

  if (content.isEmpty) return spans;

  for (var contentSpan in content) {
    /* contains superscript */
    if (contentSpan.text!.contains(tag)) {
      int tagStartIndex = contentSpan.text!.indexOf(tag) + tagLength;
      int tagEndIndex = contentSpan.text!.indexOf(endTag, tagStartIndex);

      /* add content before tag */
      if (tagStartIndex > 0) {
        spans.add(TextSpan(
            text: contentSpan.text!.substring(0, tagStartIndex - tagLength)));
      }

      String tagContent =
          contentSpan.text!.substring(tagStartIndex, tagEndIndex);

      spans.add(TextSpan(
          text: "${parse(tagContent).body!.text} ",
          style: TextStyle(fontSize: 0.7 * baseFontSize)));

      /* remaining content */
      if (tagEndIndex < contentSpan.text!.length - 1) {
        spans.addAll(_parseSuperscript([
          TextSpan(
              text: contentSpan.text!.substring(tagEndIndex + endTagLength))
        ], baseFontSize));
      }
    } else {
      spans.add(contentSpan);
    }
  }

  return spans;
}

// Parse subscripts tags <sub></sub>
List<TextSpan> _parseSubscript(List<TextSpan> content, double baseFontSize) {
  const String tag = "<sub>";
  const String endTag = "</sub>";
  const int tagLength = 5;
  const int endTagLength = 6;

  List<TextSpan> spans = [];

  if (content.isEmpty) return spans;

  for (var contentSpan in content) {
    /* contains superscript */
    if (contentSpan.text!.contains(tag)) {
      int tagStartIndex = contentSpan.text!.indexOf(tag) + tagLength;
      int tagEndIndex = contentSpan.text!.indexOf(endTag, tagStartIndex);

      /* add content before tag */
      if (tagStartIndex > 0) {
        spans.add(TextSpan(
            text: contentSpan.text!.substring(0, tagStartIndex - tagLength)));
      }

      String tagContent =
          contentSpan.text!.substring(tagStartIndex, tagEndIndex);

      spans.add(TextSpan(
          text: "${parse(tagContent).body!.text} ",
          style: TextStyle(fontSize: 0.7 * baseFontSize)));

      /* remaining content */
      if (tagEndIndex < contentSpan.text!.length - 1) {
        spans.addAll(_parseSubscript([
          TextSpan(
              text: contentSpan.text!.substring(tagEndIndex + endTagLength))
        ], baseFontSize));
      }
    } else {
      spans.add(contentSpan);
    }
  }

  return spans;
}

// Parse strong tags <strong></strong>
List<TextSpan> _parseStrongTags(List<TextSpan> content, double baseFontSize) {
  const String tag = "<strong>";
  const String endTag = "</strong>";
  const int tagLength = 8;
  const int endTagLength = 9;

  List<TextSpan> spans = [];

  if (content.isEmpty) return spans;

  for (var contentSpan in content) {
    /* contains strong tag */
    if (contentSpan.text!.contains(tag)) {
      int tagStartIndex = contentSpan.text!.indexOf(tag) + tagLength;
      int tagEndIndex = contentSpan.text!.indexOf(endTag, tagStartIndex);

      /* add content before tag */
      if (tagStartIndex > 0) {
        spans.add(TextSpan(
            text: contentSpan.text!.substring(0, tagStartIndex - tagLength)));
      }

      String tagContent =
          contentSpan.text!.substring(tagStartIndex, tagEndIndex);

      spans.add(TextSpan(
          text: "${parse(tagContent).body!.text} ",
          style: const TextStyle(fontWeight: FontWeight.bold)));

      /* remaining content */
      if (tagEndIndex < contentSpan.text!.length - 1) {
        spans.addAll(_parseStrongTags([
          TextSpan(
              text: contentSpan.text!.substring(tagEndIndex + endTagLength))
        ], baseFontSize));
      }
    } else {
      spans.add(contentSpan);
    }
  }

  return spans;
}

// Parse a tags <a></a>
List<TextSpan> _parseATags(List<TextSpan> content, double baseFontSize) {
  const String tag = "<a href=";
  const String endTag = "</a>";
  const int tagLength = 8;
  const int endTagLength = 4;

  List<TextSpan> spans = [];

  if (content.isEmpty) return spans;

  for (var contentSpan in content) {
    /* contains superscript */
    if (contentSpan.text!.contains(tag)) {
      int tagStartIndex = contentSpan.text!.indexOf(tag) + tagLength;
      int tagEndIndex = contentSpan.text!.indexOf(endTag, tagStartIndex);

      /* add content before tag */
      if (tagStartIndex > 0) {
        spans.add(TextSpan(
            text: contentSpan.text!.substring(0, tagStartIndex - tagLength)));
      }

      String tagContent =
          contentSpan.text!.substring(tagStartIndex, tagEndIndex);

      var regex = RegExp(r'<a[^>]+href=\"(.*?)\"[^>]*>(.*)?</a>');

      Match? match = regex.firstMatch("<a href=$tagContent</a>");

      String linkText = "";
      String link = "";

      if (match != null && match.groupCount >= 1) {
        link = match.group(1)!;
        linkText = match.group(2)!;
      }

      spans.add(TextSpan(
          text: "$linkText ",
          style: TextStyle(color: Colors.blue[800]),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(Uri.parse(link))) {
                await launchUrl(Uri.parse(link));
              }
            }));

      /* remaining content */
      if (tagEndIndex < contentSpan.text!.length - 1) {
        spans.addAll(_parseATags([
          TextSpan(
              text: contentSpan.text!.substring(tagEndIndex + endTagLength))
        ], baseFontSize));
      }
    } else if (contentSpan.text!.startsWith("http")) {
      spans.add(TextSpan(
          text: "${contentSpan.text!} ",
          style: TextStyle(color: Colors.blue[800]),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(Uri.parse(contentSpan.text!))) {
                await launchUrl(Uri.parse(contentSpan.text!));
              }
            }));
    } else {
      spans.add(contentSpan);
    }
  }

  return spans;
}

// HTML decode text for each TextSpan
List<TextSpan> _decodeHTML(List<TextSpan> content) {
  return content
      .map(
        (c) => TextSpan(
            text: parse(c.text).body!.text,
            style: c.style,
            recognizer: c.recognizer),
      )
      .toList();
}
