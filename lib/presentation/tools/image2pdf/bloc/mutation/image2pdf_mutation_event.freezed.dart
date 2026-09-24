// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image2pdf_mutation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Image2PdfMutationEvent {

 List<String> get imagePaths; String? get outputName;
/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Image2PdfMutationEventCopyWith<Image2PdfMutationEvent> get copyWith => _$Image2PdfMutationEventCopyWithImpl<Image2PdfMutationEvent>(this as Image2PdfMutationEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Image2PdfMutationEvent&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths)&&(identical(other.outputName, outputName) || other.outputName == outputName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(imagePaths),outputName);

@override
String toString() {
  return 'Image2PdfMutationEvent(imagePaths: $imagePaths, outputName: $outputName)';
}


}

/// @nodoc
abstract mixin class $Image2PdfMutationEventCopyWith<$Res>  {
  factory $Image2PdfMutationEventCopyWith(Image2PdfMutationEvent value, $Res Function(Image2PdfMutationEvent) _then) = _$Image2PdfMutationEventCopyWithImpl;
@useResult
$Res call({
 List<String> imagePaths, String? outputName
});




}
/// @nodoc
class _$Image2PdfMutationEventCopyWithImpl<$Res>
    implements $Image2PdfMutationEventCopyWith<$Res> {
  _$Image2PdfMutationEventCopyWithImpl(this._self, this._then);

  final Image2PdfMutationEvent _self;
  final $Res Function(Image2PdfMutationEvent) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imagePaths = null,Object? outputName = freezed,}) {
  return _then(_self.copyWith(
imagePaths: null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Image2PdfMutationEvent].
extension Image2PdfMutationEventPatterns on Image2PdfMutationEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubmitImage2Pdf value)?  submit,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubmitImage2Pdf value)  submit,}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf():
return submit(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubmitImage2Pdf value)?  submit,}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> imagePaths,  String? outputName)?  submit,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that.imagePaths,_that.outputName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> imagePaths,  String? outputName)  submit,}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf():
return submit(_that.imagePaths,_that.outputName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> imagePaths,  String? outputName)?  submit,}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that.imagePaths,_that.outputName);case _:
  return null;

}
}

}

/// @nodoc


class SubmitImage2Pdf implements Image2PdfMutationEvent {
  const SubmitImage2Pdf(this.imagePaths, {this.outputName});
  

@override final  List<String> imagePaths;
@override final  String? outputName;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitImage2PdfCopyWith<SubmitImage2Pdf> get copyWith => _$SubmitImage2PdfCopyWithImpl<SubmitImage2Pdf>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitImage2Pdf&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths)&&(identical(other.outputName, outputName) || other.outputName == outputName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(imagePaths),outputName);

@override
String toString() {
  return 'Image2PdfMutationEvent.submit(imagePaths: $imagePaths, outputName: $outputName)';
}


}

/// @nodoc
abstract mixin class $SubmitImage2PdfCopyWith<$Res> implements $Image2PdfMutationEventCopyWith<$Res> {
  factory $SubmitImage2PdfCopyWith(SubmitImage2Pdf value, $Res Function(SubmitImage2Pdf) _then) = _$SubmitImage2PdfCopyWithImpl;
@override @useResult
$Res call({
 List<String> imagePaths, String? outputName
});




}
/// @nodoc
class _$SubmitImage2PdfCopyWithImpl<$Res>
    implements $SubmitImage2PdfCopyWith<$Res> {
  _$SubmitImage2PdfCopyWithImpl(this._self, this._then);

  final SubmitImage2Pdf _self;
  final $Res Function(SubmitImage2Pdf) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imagePaths = null,Object? outputName = freezed,}) {
  return _then(SubmitImage2Pdf(
null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
