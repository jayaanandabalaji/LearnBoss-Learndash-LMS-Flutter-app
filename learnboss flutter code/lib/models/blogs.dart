import 'package:json_annotation/json_annotation.dart';

part 'blogs.g.dart';

// ignore_for_file: prefer_typing_uninitialized_variables
@JsonSerializable()
class Blogs {
  int id;
  String modified;
  String link;
  TitleBean title;
  ContentBean content;
  @JsonKey(name: "_links")
  final links;
  @JsonKey(name: "_embedded")
  final embedded;
  final details;
  Blogs(
      {required this.id,
      required this.modified,
      required this.link,
      required this.title,
      required this.content,
      required this.links,
      required this.embedded,
      this.details});
  factory Blogs.fromJson(Map<String, dynamic> json) => _$BlogsFromJson(json);
  Map<String, dynamic> toJson() => _$BlogsToJson(this);
}

@JsonSerializable()
class TitleBean {
  String rendered;
  TitleBean({this.rendered = ""});
  factory TitleBean.fromJson(Map<String, dynamic> json) =>
      _$TitleBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TitleBeanToJson(this);
}

@JsonSerializable()
class ContentBean {
  String rendered;
  ContentBean({this.rendered = ""});
  factory ContentBean.fromJson(Map<String, dynamic> json) =>
      _$ContentBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ContentBeanToJson(this);
}
