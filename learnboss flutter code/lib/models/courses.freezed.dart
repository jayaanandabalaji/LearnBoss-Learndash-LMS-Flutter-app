// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'courses.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get enrolled => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get updated => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String get price_type => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  Curriculum get curriculum => throw _privateConstructorUsedError;
  int get lectures => throw _privateConstructorUsedError;
  dynamic get category => throw _privateConstructorUsedError;
  dynamic get instructor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call(
      {int id,
      String title,
      bool enrolled,
      String link,
      String updated,
      String image,
      String price_type,
      String price,
      String content,
      Curriculum curriculum,
      int lectures,
      dynamic category,
      dynamic instructor});

  $CurriculumCopyWith<$Res> get curriculum;
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? enrolled = null,
    Object? link = null,
    Object? updated = null,
    Object? image = null,
    Object? price_type = null,
    Object? price = null,
    Object? content = null,
    Object? curriculum = null,
    Object? lectures = null,
    Object? category = freezed,
    Object? instructor = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      enrolled: null == enrolled
          ? _value.enrolled
          : enrolled // ignore: cast_nullable_to_non_nullable
              as bool,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      price_type: null == price_type
          ? _value.price_type
          : price_type // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      curriculum: null == curriculum
          ? _value.curriculum
          : curriculum // ignore: cast_nullable_to_non_nullable
              as Curriculum,
      lectures: null == lectures
          ? _value.lectures
          : lectures // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as dynamic,
      instructor: freezed == instructor
          ? _value.instructor
          : instructor // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CurriculumCopyWith<$Res> get curriculum {
    return $CurriculumCopyWith<$Res>(_value.curriculum, (value) {
      return _then(_value.copyWith(curriculum: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_CourseCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$_CourseCopyWith(_$_Course value, $Res Function(_$_Course) then) =
      __$$_CourseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      bool enrolled,
      String link,
      String updated,
      String image,
      String price_type,
      String price,
      String content,
      Curriculum curriculum,
      int lectures,
      dynamic category,
      dynamic instructor});

  @override
  $CurriculumCopyWith<$Res> get curriculum;
}

/// @nodoc
class __$$_CourseCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$_Course>
    implements _$$_CourseCopyWith<$Res> {
  __$$_CourseCopyWithImpl(_$_Course _value, $Res Function(_$_Course) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? enrolled = null,
    Object? link = null,
    Object? updated = null,
    Object? image = null,
    Object? price_type = null,
    Object? price = null,
    Object? content = null,
    Object? curriculum = null,
    Object? lectures = null,
    Object? category = freezed,
    Object? instructor = freezed,
  }) {
    return _then(_$_Course(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      enrolled: null == enrolled
          ? _value.enrolled
          : enrolled // ignore: cast_nullable_to_non_nullable
              as bool,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      price_type: null == price_type
          ? _value.price_type
          : price_type // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      curriculum: null == curriculum
          ? _value.curriculum
          : curriculum // ignore: cast_nullable_to_non_nullable
              as Curriculum,
      lectures: null == lectures
          ? _value.lectures
          : lectures // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as dynamic,
      instructor: freezed == instructor
          ? _value.instructor
          : instructor // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Course implements _Course {
  _$_Course(
      {required this.id,
      required this.title,
      required this.enrolled,
      required this.link,
      required this.updated,
      required this.image,
      required this.price_type,
      required this.price,
      required this.content,
      required this.curriculum,
      required this.lectures,
      required this.category,
      required this.instructor});

  factory _$_Course.fromJson(Map<String, dynamic> json) =>
      _$$_CourseFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final bool enrolled;
  @override
  final String link;
  @override
  final String updated;
  @override
  final String image;
  @override
  final String price_type;
  @override
  final String price;
  @override
  final String content;
  @override
  final Curriculum curriculum;
  @override
  final int lectures;
  @override
  final dynamic category;
  @override
  final dynamic instructor;

  @override
  String toString() {
    return 'Course(id: $id, title: $title, enrolled: $enrolled, link: $link, updated: $updated, image: $image, price_type: $price_type, price: $price, content: $content, curriculum: $curriculum, lectures: $lectures, category: $category, instructor: $instructor)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Course &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.enrolled, enrolled) ||
                other.enrolled == enrolled) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.updated, updated) || other.updated == updated) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.price_type, price_type) ||
                other.price_type == price_type) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.curriculum, curriculum) ||
                other.curriculum == curriculum) &&
            (identical(other.lectures, lectures) ||
                other.lectures == lectures) &&
            const DeepCollectionEquality().equals(other.category, category) &&
            const DeepCollectionEquality()
                .equals(other.instructor, instructor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      enrolled,
      link,
      updated,
      image,
      price_type,
      price,
      content,
      curriculum,
      lectures,
      const DeepCollectionEquality().hash(category),
      const DeepCollectionEquality().hash(instructor));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CourseCopyWith<_$_Course> get copyWith =>
      __$$_CourseCopyWithImpl<_$_Course>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CourseToJson(
      this,
    );
  }
}

abstract class _Course implements Course {
  factory _Course(
      {required final int id,
      required final String title,
      required final bool enrolled,
      required final String link,
      required final String updated,
      required final String image,
      required final String price_type,
      required final String price,
      required final String content,
      required final Curriculum curriculum,
      required final int lectures,
      required final dynamic category,
      required final dynamic instructor}) = _$_Course;

  factory _Course.fromJson(Map<String, dynamic> json) = _$_Course.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  bool get enrolled;
  @override
  String get link;
  @override
  String get updated;
  @override
  String get image;
  @override
  String get price_type;
  @override
  String get price;
  @override
  String get content;
  @override
  Curriculum get curriculum;
  @override
  int get lectures;
  @override
  dynamic get category;
  @override
  dynamic get instructor;
  @override
  @JsonKey(ignore: true)
  _$$_CourseCopyWith<_$_Course> get copyWith =>
      throw _privateConstructorUsedError;
}

Curriculum _$CurriculumFromJson(Map<String, dynamic> json) {
  return _Curriculum.fromJson(json);
}

/// @nodoc
mixin _$Curriculum {
  dynamic get structure => throw _privateConstructorUsedError;
  LessonDetails get lesson_details => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CurriculumCopyWith<Curriculum> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurriculumCopyWith<$Res> {
  factory $CurriculumCopyWith(
          Curriculum value, $Res Function(Curriculum) then) =
      _$CurriculumCopyWithImpl<$Res, Curriculum>;
  @useResult
  $Res call({dynamic structure, LessonDetails lesson_details});

  $LessonDetailsCopyWith<$Res> get lesson_details;
}

/// @nodoc
class _$CurriculumCopyWithImpl<$Res, $Val extends Curriculum>
    implements $CurriculumCopyWith<$Res> {
  _$CurriculumCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? structure = freezed,
    Object? lesson_details = null,
  }) {
    return _then(_value.copyWith(
      structure: freezed == structure
          ? _value.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as dynamic,
      lesson_details: null == lesson_details
          ? _value.lesson_details
          : lesson_details // ignore: cast_nullable_to_non_nullable
              as LessonDetails,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LessonDetailsCopyWith<$Res> get lesson_details {
    return $LessonDetailsCopyWith<$Res>(_value.lesson_details, (value) {
      return _then(_value.copyWith(lesson_details: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_CurriculumCopyWith<$Res>
    implements $CurriculumCopyWith<$Res> {
  factory _$$_CurriculumCopyWith(
          _$_Curriculum value, $Res Function(_$_Curriculum) then) =
      __$$_CurriculumCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic structure, LessonDetails lesson_details});

  @override
  $LessonDetailsCopyWith<$Res> get lesson_details;
}

/// @nodoc
class __$$_CurriculumCopyWithImpl<$Res>
    extends _$CurriculumCopyWithImpl<$Res, _$_Curriculum>
    implements _$$_CurriculumCopyWith<$Res> {
  __$$_CurriculumCopyWithImpl(
      _$_Curriculum _value, $Res Function(_$_Curriculum) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? structure = freezed,
    Object? lesson_details = null,
  }) {
    return _then(_$_Curriculum(
      structure: freezed == structure
          ? _value.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as dynamic,
      lesson_details: null == lesson_details
          ? _value.lesson_details
          : lesson_details // ignore: cast_nullable_to_non_nullable
              as LessonDetails,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Curriculum implements _Curriculum {
  _$_Curriculum({required this.structure, required this.lesson_details});

  factory _$_Curriculum.fromJson(Map<String, dynamic> json) =>
      _$$_CurriculumFromJson(json);

  @override
  final dynamic structure;
  @override
  final LessonDetails lesson_details;

  @override
  String toString() {
    return 'Curriculum(structure: $structure, lesson_details: $lesson_details)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Curriculum &&
            const DeepCollectionEquality().equals(other.structure, structure) &&
            (identical(other.lesson_details, lesson_details) ||
                other.lesson_details == lesson_details));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(structure), lesson_details);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CurriculumCopyWith<_$_Curriculum> get copyWith =>
      __$$_CurriculumCopyWithImpl<_$_Curriculum>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CurriculumToJson(
      this,
    );
  }
}

abstract class _Curriculum implements Curriculum {
  factory _Curriculum(
      {required final dynamic structure,
      required final LessonDetails lesson_details}) = _$_Curriculum;

  factory _Curriculum.fromJson(Map<String, dynamic> json) =
      _$_Curriculum.fromJson;

  @override
  dynamic get structure;
  @override
  LessonDetails get lesson_details;
  @override
  @JsonKey(ignore: true)
  _$$_CurriculumCopyWith<_$_Curriculum> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonDetails _$LessonDetailsFromJson(Map<String, dynamic> json) {
  return _LessonDetails.fromJson(json);
}

/// @nodoc
mixin _$LessonDetails {
  dynamic get topics => throw _privateConstructorUsedError;
  dynamic get sections => throw _privateConstructorUsedError;
  dynamic get quizzes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonDetailsCopyWith<LessonDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonDetailsCopyWith<$Res> {
  factory $LessonDetailsCopyWith(
          LessonDetails value, $Res Function(LessonDetails) then) =
      _$LessonDetailsCopyWithImpl<$Res, LessonDetails>;
  @useResult
  $Res call({dynamic topics, dynamic sections, dynamic quizzes});
}

/// @nodoc
class _$LessonDetailsCopyWithImpl<$Res, $Val extends LessonDetails>
    implements $LessonDetailsCopyWith<$Res> {
  _$LessonDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topics = freezed,
    Object? sections = freezed,
    Object? quizzes = freezed,
  }) {
    return _then(_value.copyWith(
      topics: freezed == topics
          ? _value.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as dynamic,
      sections: freezed == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as dynamic,
      quizzes: freezed == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LessonDetailsCopyWith<$Res>
    implements $LessonDetailsCopyWith<$Res> {
  factory _$$_LessonDetailsCopyWith(
          _$_LessonDetails value, $Res Function(_$_LessonDetails) then) =
      __$$_LessonDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic topics, dynamic sections, dynamic quizzes});
}

/// @nodoc
class __$$_LessonDetailsCopyWithImpl<$Res>
    extends _$LessonDetailsCopyWithImpl<$Res, _$_LessonDetails>
    implements _$$_LessonDetailsCopyWith<$Res> {
  __$$_LessonDetailsCopyWithImpl(
      _$_LessonDetails _value, $Res Function(_$_LessonDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topics = freezed,
    Object? sections = freezed,
    Object? quizzes = freezed,
  }) {
    return _then(_$_LessonDetails(
      topics: freezed == topics
          ? _value.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as dynamic,
      sections: freezed == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as dynamic,
      quizzes: freezed == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LessonDetails implements _LessonDetails {
  _$_LessonDetails(
      {required this.topics, required this.sections, required this.quizzes});

  factory _$_LessonDetails.fromJson(Map<String, dynamic> json) =>
      _$$_LessonDetailsFromJson(json);

  @override
  final dynamic topics;
  @override
  final dynamic sections;
  @override
  final dynamic quizzes;

  @override
  String toString() {
    return 'LessonDetails(topics: $topics, sections: $sections, quizzes: $quizzes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LessonDetails &&
            const DeepCollectionEquality().equals(other.topics, topics) &&
            const DeepCollectionEquality().equals(other.sections, sections) &&
            const DeepCollectionEquality().equals(other.quizzes, quizzes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(topics),
      const DeepCollectionEquality().hash(sections),
      const DeepCollectionEquality().hash(quizzes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LessonDetailsCopyWith<_$_LessonDetails> get copyWith =>
      __$$_LessonDetailsCopyWithImpl<_$_LessonDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LessonDetailsToJson(
      this,
    );
  }
}

abstract class _LessonDetails implements LessonDetails {
  factory _LessonDetails(
      {required final dynamic topics,
      required final dynamic sections,
      required final dynamic quizzes}) = _$_LessonDetails;

  factory _LessonDetails.fromJson(Map<String, dynamic> json) =
      _$_LessonDetails.fromJson;

  @override
  dynamic get topics;
  @override
  dynamic get sections;
  @override
  dynamic get quizzes;
  @override
  @JsonKey(ignore: true)
  _$$_LessonDetailsCopyWith<_$_LessonDetails> get copyWith =>
      throw _privateConstructorUsedError;
}
