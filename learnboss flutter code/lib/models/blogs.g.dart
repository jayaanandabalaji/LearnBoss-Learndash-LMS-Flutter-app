// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blogs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blogs _$BlogsFromJson(Map<String, dynamic> json) => Blogs(
      id: json['id'] as int,
      modified: json['modified'] as String,
      link: json['link'] as String,
      title: TitleBean.fromJson(json['title'] as Map<String, dynamic>),
      content: ContentBean.fromJson(json['content'] as Map<String, dynamic>),
      links: json['_links'],
      embedded: json['_embedded'],
      details: json['details'],
    );

Map<String, dynamic> _$BlogsToJson(Blogs instance) => <String, dynamic>{
      'id': instance.id,
      'modified': instance.modified,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      '_links': instance.links,
      '_embedded': instance.embedded,
      'details': instance.details,
    };

TitleBean _$TitleBeanFromJson(Map<String, dynamic> json) => TitleBean(
      rendered: json['rendered'] as String? ?? "",
    );

Map<String, dynamic> _$TitleBeanToJson(TitleBean instance) => <String, dynamic>{
      'rendered': instance.rendered,
    };

ContentBean _$ContentBeanFromJson(Map<String, dynamic> json) => ContentBean(
      rendered: json['rendered'] as String? ?? "",
    );

Map<String, dynamic> _$ContentBeanToJson(ContentBean instance) =>
    <String, dynamic>{
      'rendered': instance.rendered,
    };
