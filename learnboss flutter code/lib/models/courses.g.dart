// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
_$_Course _$$_CourseFromJson(Map<String, dynamic> json) => _$_Course(
      id: json['id'] as int,
      title: json['title'] as String,
      enrolled: json['enrolled'] as bool,
      link: json['link'] as String,
      updated: json['updated'] as String,
      image: json['image'] as String,
      price_type: json['price_type'] as String,
      price: json['price'] as String,
      content: json['content'] as String,
      curriculum:
          Curriculum.fromJson(json['curriculum'] as Map<String, dynamic>),
      lectures: json['lectures'] as int,
      category: json['category'],
      instructor: json['instructor'],
    );

Map<String, dynamic> _$$_CourseToJson(_$_Course instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'enrolled': instance.enrolled,
      'link': instance.link,
      'updated': instance.updated,
      'image': instance.image,
      'price_type': instance.price_type,
      'price': instance.price,
      'content': instance.content,
      'curriculum': instance.curriculum,
      'lectures': instance.lectures,
      'category': instance.category,
      'instructor': instance.instructor,
    };

_$_Curriculum _$$_CurriculumFromJson(Map<String, dynamic> json) =>
    _$_Curriculum(
      structure: json['structure'],
      lesson_details: LessonDetails.fromJson(
          json['lesson_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_CurriculumToJson(_$_Curriculum instance) =>
    <String, dynamic>{
      'structure': instance.structure,
      'lesson_details': instance.lesson_details,
    };

_$_LessonDetails _$$_LessonDetailsFromJson(Map<String, dynamic> json) =>
    _$_LessonDetails(
      topics: json['topics'],
      sections: json['sections'],
      quizzes: json['quizzes'],
    );

Map<String, dynamic> _$$_LessonDetailsToJson(_$_LessonDetails instance) =>
    <String, dynamic>{
      'topics': instance.topics,
      'sections': instance.sections,
      'quizzes': instance.quizzes,
    };
