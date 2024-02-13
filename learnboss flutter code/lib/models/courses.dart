import 'package:freezed_annotation/freezed_annotation.dart';

part 'courses.freezed.dart';
part 'courses.g.dart';

// ignore_for_file: non_constant_identifier_names
@freezed
class Course with _$Course {
  factory Course(
      {required int id,
      required String title,
      required bool enrolled,
      required String link,
      required String updated,
      required String image,
      required String price_type,
      required String price,
      required String content,
      required Curriculum curriculum,
      required int lectures,
      required dynamic category,
      required dynamic instructor}) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@freezed
class Curriculum with _$Curriculum {
  factory Curriculum(
      {required dynamic structure,
      required LessonDetails lesson_details}) = _Curriculum;

  factory Curriculum.fromJson(Map<String, dynamic> json) =>
      _$CurriculumFromJson(json);
}

@freezed
class LessonDetails with _$LessonDetails {
  factory LessonDetails(
      {required dynamic topics,
      required dynamic sections,
      required dynamic quizzes}) = _LessonDetails;

  factory LessonDetails.fromJson(Map<String, dynamic> json) =>
      _$LessonDetailsFromJson(json);
}
